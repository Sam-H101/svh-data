# svh-data

Signed, versioned game-data patches for the svh server (Survarium x64 v0.69d0). The files a
release ships are installed by the player-side client; the server only offers them.

## Releases

Each release `data-vN` carries:

| Asset | What |
|---|---|
| `manifest.json` | `data_version`, `data_id` (sha256 over the sorted `path<TAB>sha256` lines of its files), the game build it is for (file digests), and every file: the game path it replaces, its sha256 and size, the sha256 of the stock file it replaces, and the release asset that holds it |
| `manifest.json.sig` | Ed25519 signature over the exact bytes of `manifest.json`, base64 |
| one asset per file | the patched file itself |
| `data-signing.pub.pem` | the public key (also in `keys/`) |

A client must verify `manifest.json.sig` with the public key it already trusts (not one it
downloaded), then check every file's sha256 against the manifest, and use a file only when the
stock file it replaces has the listed sha256.

Verify by hand with OpenSSL 3:

```
base64 -d manifest.json.sig > manifest.sig.bin
openssl pkeyutl -verify -rawin -pubin -inkey data-signing.pub.pem -in manifest.json -sigfile manifest.sig.bin
sha256sum lobby_menu.gfx
```

## Signing key

Ed25519, key id `a0fa25ecb8c46f7f` (first 16 hex digits of the sha256 of the raw 32-byte public
key). Public key: [`keys/data-signing.pub.pem`](keys/data-signing.pub.pem). The private key is
held by the main host server and never stored in this repository.

## Sources

| Path | What |
|---|---|
| [`ui/exchange/`](ui/exchange/) | The exchange window with a silver-to-gold row: ActionScript source, build steps and tools. Built into `lobby_menu.gfx` (releases `data-v1`, `data-v2`: the gold "+" opens it too). |
