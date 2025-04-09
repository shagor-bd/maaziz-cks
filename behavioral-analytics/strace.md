# STRACE
To count and filter the system calls from the `strace ls` output, you can use several approaches. Here are some useful methods:

### 1. **Count Total System Calls**
To count the total number of system calls made by `ls`, you can use:

```bash
strace ls 2>&1 | wc -l
```

This counts all lines in the output, but note that some system calls span multiple lines.

### 2. **List Unique System Calls**
To list all unique system calls used:

```bash
strace ls 2>&1 | grep -oP '^\w+\(' | sort | uniq -c
```

**Explanation:**
- `grep -oP '^\w+\('` → Extracts system call names (e.g., `openat(`).
- `sort | uniq -c` → Counts occurrences of each unique system call.

### 3. **Filter Specific System Calls**
If you want to see only specific system calls (e.g., `openat`):

```bash
strace ls 2>&1 | grep '^openat'
```

### 4. **Count System Calls Without Arguments**
To get a cleaner count (excluding arguments):

```bash
strace ls 2>&1 | cut -d'(' -f1 | sort | uniq -c
```

### 5. **Using `strace` Summary Mode**
For a quick summary of system calls (including counts):

```bash
strace -c ls
```

**Output Example:**
```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  xx.xx    0.xxxxxx          xx        xx         xx openat
  xx.xx    0.xxxxxx          xx        xx         xx read
  ...
------ ----------- ----------- --------- --------- ----------------
100.00    0.xxxxxx                     xx         xx total
```

### **Example Output for Your Case**
If you run:
```bash
strace ls 2>&1 | grep -oP '^\w+\(' | sort | uniq -c
```

You might see something like:
```
      1 access(
      1 arch_prctl(
      1 brk(
      1 close(
      1 execve(
      1 exit_group(
      1 fstat(
      1 getdents64(
      1 getrandom(
      1 ioctl(
      1 mmap(
      1 mprotect(
      1 munmap(
      1 openat(
      1 prlimit64(
      1 read(
      1 rseq(
      1 set_robust_list(
      1 set_tid_address(
      1 statfs(
      1 write(
```

### **Conclusion**
- **Total syscalls:** ~20–30 (depends on `ls` implementation and environment).
- **Most frequent:** `openat`, `mmap`, `close`, `fstat`, `read`.

For a precise count, use `strace -c ls`.

