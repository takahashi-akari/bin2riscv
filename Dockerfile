FROM ubuntu:22.04

# 基本ツール
RUN apt-get update && apt-get install -y \
    build-essential clang lld lldb git curl python3 python3-pip \
    qemu-user retdec wget unzip cmake ninja-build \
    && apt-get clean

# Set working directory
WORKDIR /workspace

# 環境変数（RetDecを使いやすく）
ENV PATH="/usr/bin:$PATH"

# コピーして実行できるように
COPY bin2riscv.py .
COPY intrin_shim.h .
COPY linker.ld .
COPY bin2riscv.sh .
COPY intrin_shims.sh .

RUN chmod +x bin2riscv.sh intrin_shims.sh

# デフォルトコマンド（x86 ELFを入れてシェル実行）
CMD ["/bin/bash"]
