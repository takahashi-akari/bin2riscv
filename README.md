# bin2riscv

📦 Convert your legacy `x86_64` Linux executable binaries to `RISC-V` ELF binaries — as automatically as possible.

---

## 🚀 What is this?

`bin2riscv` is a proof-of-concept CLI tool that takes an **x86_64 executable**, decompiles it to C using [RetDec](https://github.com/avast/retdec), applies basic transformations for portability, and recompiles it as a **RISC-V ELF** binary using `clang`.

---

## ✨ Features

- ✅ Decompile x86_64 ELF to C
- ✅ Auto-patch for portability (`__int64` → `int64_t`, etc.)
- ✅ Replace Intel Intrinsics with RISC-V shim functions
- ✅ Compile using `clang --target=riscv64-unknown-elf`
- ✅ Optionally run in `qemu-riscv64`

---

## 🛠 Requirements

- Python 3.x
- [`retdec`](https://github.com/avast/retdec) (must be in PATH)
- `clang` with RISC-V backend
- `ld.lld` (for linking)
- `qemu-riscv64` (optional for testing)

---

## 📦 Install

```bash
git clone https://github.com/yourname/bin2riscv.git
cd bin2riscv
```

---

## 🔧 Usage

```bash
python bin2riscv.py your_binary.out
```

This will generate:
- `your_binary.c`: Decompiled C source
- `your_binary_riscv.elf`: RISC-V executable
- `intrin_shim.h`: Generated Intrinsics header

If `qemu-riscv64` is available, it will run the binary too.

---

## 🔍 Limitations

- Only simple binaries are supported for now (no dynamic linking, no syscalls)
- Intrinsics mapping is minimal (only `_mm_add_pd` supported)
- Reverse-engineered function names may be placeholder (`func_1`, etc.)
- Not a security tool — purely experimental

---

## 📅 Roadmap

- [ ] Add more intrinsics to shim generator
- [ ] Support custom `linker.ld` generation
- [ ] Extend to support dynamic binaries
- [ ] Build full LLVM IR pipeline (optional path)
- [ ] Web UI?

---

## 🧠 Author

Created by [takahashi-akari] — powered by curiosity and low-level wizardry.

---

## 📜 License

MIT
