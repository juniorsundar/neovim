#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
DIST="$ROOT/dist"
STAGE="$DIST/nvremote-nvim-linux-x86_64"

rm -rf "$STAGE"
mkdir -p "$STAGE/lib"

# Install Neovim + matching runtime.
cmake --install "$ROOT/build" --prefix "$STAGE"

# Preserve the real Neovim executable.
mv "$STAGE/bin/nvim" "$STAGE/bin/nvim.real"

# Bundle the musl runtime dependencies.
cp /lib/ld-musl-x86_64.so.1 "$STAGE/lib/"
cp /usr/lib/libgcc_s.so.1 "$STAGE/lib/"

# User-facing launcher.
cat > "$STAGE/bin/nvim" <<'EOF'
#!/bin/sh
set -eu

BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$BIN_DIR/.." && pwd)

exec "$ROOT/lib/ld-musl-x86_64.so.1" \
  --library-path "$ROOT/lib" \
  "$BIN_DIR/nvim.real" \
  "$@"
EOF

chmod +x "$STAGE/bin/nvim"

tar -C "$STAGE" \
  -czf "$DIST/nvremote-nvim-linux-x86_64.tar.gz" \
  .

cd "$DIST"

sha256sum \
  nvremote-nvim-linux-x86_64.tar.gz \
  > nvremote-nvim-linux-x86_64.tar.gz.sha256

echo "$DIST/nvremote-nvim-linux-x86_64.tar.gz"
echo "$DIST/nvremote-nvim-linux-x86_64.tar.gz.sha256"
