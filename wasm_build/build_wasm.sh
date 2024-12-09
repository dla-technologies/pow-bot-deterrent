#!/bin/bash -e

if [ ! -f build_wasm.sh ]; then
  printf "Please run this script from the wasm_build folder.\n"
fi

if [ ! -d scrypt-wasm ]; then
  printf "Cloning https://github.com/MyEtherWallet/scrypt-wasm... \n"
  git clone https://github.com/MyEtherWallet/scrypt-wasm
fi

cd scrypt-wasm

rust_is_installed="$(which rustc | wc -l)"

if [ "$rust_is_installed" == "0" ]; then
  printf "rust language compilers & tools will need to be installed."
  printf "using rustup.rs: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh \n"
  read -p "is this ok? [y] " -n 1 -r
  printf "\n"
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  else
      printf "exiting due to no rust compiler"
      exit 1
  fi
fi

if [ ! -d pkg ]; then
  printf "running Makefile for MyEtherWallet/scrypt-wasm... \n"
	rustup target add wasm32-unknown-unknown
	cargo install wasm-pack --force
	wasm-pack build --target no-modules
fi

cd ../

cp scrypt-wasm/pkg/scrypt_wasm_bg.wasm ../static/

echo '
// THIS FILE IS GENERATED AUTOMATICALLY
// Dont edit this file by hand. 
// Either edit proofOfWorkerStub.js or edit the build located in the wasm_build folder.
' > ../static/proofOfWorker.js

cat ../proofOfWorkerStub.js | tail -n +6  >> ../static/proofOfWorker.js

cat scrypt-wasm/pkg/scrypt_wasm.js >> ../static/proofOfWorker.js

# see: https://rustwasm.github.io/docs/wasm-bindgen/examples/without-a-bundler.html
echo '
scrypt = wasm_bindgen.scrypt;
scryptPromise = wasm_bindgen({module_or_path: "/static/scrypt.wasm"});

' >> ../static/proofOfWorker.js

echo "Build successful!"