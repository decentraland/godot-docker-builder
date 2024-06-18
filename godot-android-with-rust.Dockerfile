FROM kuruk/dcl-godot-android-builder:latest

## Cargo + Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain=1.77.2 -y

ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add aarch64-linux-android
RUN rustup target add x86_64-linux-android
