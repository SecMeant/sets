#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string_view>

#include <pcre2.h>

#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>
#include <pty.h>

static constexpr int INVALID_PID = -1;

static constexpr std::string_view str_longest_ipv4 = "255.255.255.255/99";
static constexpr std::string_view str_longest_mac  = "FF:FF:FF:FF:FF:FF";

static constexpr size_t str_longest_ipv4_len = str_longest_ipv4.size() + 1;
static constexpr size_t str_longest_mac_len  = str_longest_mac.size() + 1;

struct machine_info
{
	char name[16];
	char ip[str_longest_ipv4_len];
	char mac[str_longest_mac_len];
};

static machine_info MACHINES[] = {
	[0] = {
		.name = "defiled",
		.ip = "",
		.mac = "56:d3:f1:7e:d0:00",
	},
	[1] = {
		.name = "defiled",
		.ip = "",
		.mac = "56:54:d3:f1:7e:d0",
	},
};

struct process_info
{
	static constexpr size_t FD_COUNT = 3;

	constexpr process_info()
		: _pid { INVALID_PID }
		// , fds { -1, -1, -1 }
		, _stdout { -1 }
	{
	}

	//constexpr auto& stdin()
	//{
	//	return this->fds[STDIN_FILENO];
	//}

	constexpr auto& stdout()
	{
		return this->_stdout;
	}

	//constexpr auto& stderr()
	//{
	//	return this->fds[STDERR_FILENO];
	//}
	
	~process_info()
	{
		if (this->_stdout != -1) {
			close(this->_stdout);
			this->_stdout = -1;
		}

		if (this->_pid != INVALID_PID) {
			close(this->_pid);
			this->_pid = INVALID_PID;
		}
	}

	pid_t _pid;
	//std::array<int, FD_COUNT> fds;
	int _stdout;
};

static process_info
create_process(const char *filepath, const char **argv)
{
	process_info newproc;
	//int new_stdin[2], new_stdout[2], new_stderr[2];
	int new_stdout[2];

	//if (pipe(new_stdin))
	//	goto bad_pipe_stdin;

	if (pipe(new_stdout))
		goto bad_pipe_stdout;

	//if (pipe(new_stderr))
	//	goto bad_pipe_stderr;

	//newproc.stdin()  = new_stdin[1];
	newproc.stdout() = new_stdout[0];
	//newproc.stderr() = new_stderr[0];

	newproc._pid = fork();

	if (newproc._pid == 0) {
		//
		// Don't close stdin and stderr because some programs freak out
		// if they don't have them opened on standard fds.
		//
		// close(STDIN_FILENO);
		// close(STDOUT_FILENO);
		// close(STDERR_FILENO);

		//dup2(new_stdin[0], STDIN_FILENO);
		//close(new_stdin[0]);
		//close(new_stdin[1]);

		dup2(new_stdout[1], STDOUT_FILENO);
		close(new_stdout[0]);
		close(new_stdout[1]);

		//dup2(new_stderr[1], STDERR_FILENO);
		//close(new_stderr[0]);
		//close(new_stderr[1]);

		execvp(filepath, const_cast<char * const *>(argv));
		exit(-1);
	}

	//close(new_stdin[1]);
	close(new_stdout[1]);
	//close(new_stderr[1]);

	newproc._stdout = new_stdout[0];
	return newproc;

//bad_pipe_stderr:
//	close(new_stdout[0]);
//	close(new_stdout[1]);

bad_pipe_stdout:
	//close(new_stdin[0]);
	//close(new_stdin[1]);

//bad_pipe_stdin:

	newproc._pid = INVALID_PID;
	return newproc;
}

static pid_t
wait_for_process(const process_info &p, int *errc, int flags)
{
	return waitpid(p._pid, errc, flags);
}

static pid_t
wait_for_process(const process_info &p)
{
	int errc;
	return wait_for_process(p, &errc, 0);
}

static FILE*
to_fileptr(process_info &&p)
{
	FILE *ret = fdopen(p._stdout, "r");
	p._stdout = -1;

	return ret;
}

static const char *
get_host_network_addr()
{
	return "192.168.100.0/24";
}

static int
ping_hosts()
{
	const char *host_network_addr = get_host_network_addr();

	const char *argv[] = {
		"nmap",
		"-sP",
		host_network_addr,
		NULL,
	};

	auto p = create_process("nmap", argv);

	if (p._pid == -1)
		return -1;

	int errc = 0;
	wait_for_process(p, &errc, 0);

	return errc;
}

static constexpr std::string_view IP_MAC_PAIR_PATTERN = "\\((\\d+\\.\\d+\\.\\d+\\.\\d+)\\).*(([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2}))";
pcre2_code *re;
pcre2_match_data *match_data;

struct {
	unsigned verbose   : 1 = 0;
	unsigned skip_ping : 1 = 0;
} static opts;

static void parse_args(int argc, char **argv)
{
	for (int i = 0; i < argc; ++i) {
		if (strcmp(argv[i], "-p") == 0)
			opts.skip_ping = 1;
		else if(strcmp(argv[i], "-v") == 0)
			opts.verbose = 1;
	}
}

int main(int argc, char **argv)
{
	parse_args(argc, argv);

	/* Init PCRE2 */
	int errorcode = 0;
	size_t erroroffset = 0;
	re = pcre2_compile((PCRE2_SPTR) IP_MAC_PAIR_PATTERN.data(), IP_MAC_PAIR_PATTERN.size(), 0, &errorcode, &erroroffset, NULL);

	if (re == nullptr) {
		PCRE2_UCHAR buffer[256];
		pcre2_get_error_message(errorcode, buffer, sizeof(buffer));
		printf("PCRE2 compilation failed at offset %lu: %s\n", erroroffset, buffer);
		return 1;
	}

	match_data = pcre2_match_data_create_from_pattern(re, NULL);


	/* Ping all hosts and then parse (hopefully) populated arp table */
	if (!opts.skip_ping) {
		if (int ret = ping_hosts(); ret) {
			fprintf(stderr, "ping_hosts() failed\n");
			return 1;
		}
	}

	const char *arp_argv[] = {
		"arp",
		"-an",
		NULL,
	};

	auto p = create_process("arp", arp_argv);

	if (p._pid == -1)
		return 1;

	// We leak the buffers, let the kernel do the cleanup
	FILE *arp_stdout = to_fileptr(std::move(p));
	char *line = nullptr;
	size_t line_len = 0;

	for (;;) {
		ssize_t nread = getline(&line, &line_len, arp_stdout);

		if (nread <= 1)
			break;

		int rc = pcre2_match (
			re,
			reinterpret_cast<PCRE2_SPTR>(line),
			line_len,
			0,
			0,
			match_data,
			NULL
		);

		if (rc < 0) {
			if (rc == PCRE2_ERROR_NOMATCH) {
				//printf("no match\n");
				continue;
			}

			printf("Matching error: %d\n", rc);
			break;
		}

		// Sanity check, it should never happen
		if (rc != 3) {
			//printf("WARNING: Unexpected number of matches = %d\n", rc);
		}

		PCRE2_SIZE *ovector = pcre2_get_ovector_pointer(match_data);

		auto ip  = std::string_view(line + ovector[1*2], line + ovector[1*2+1]);
		auto mac = std::string_view(line + ovector[2*2], line + ovector[2*2+1]);

		if (opts.verbose)
			printf("[?] Matched: IP: %.*s, MAC: %.*s\n", (int)ip.size(), ip.data(), (int)mac.size(), mac.data());

		for (auto & m: MACHINES) {
			if (mac == m.mac) {
				strncpy(m.ip, ip.data(), ip.size());
				m.ip[ip.size()] = 0;
				printf("[+] Found machine %s:\n\tIP: %s\n\tMAC: %s\n\texport %s=%s\n", m.name, m.ip, m.mac, m.name, m.ip);
			}
		}
	}

	return 0;
}
