build:
  mkdir -p ../boom-client/assets/resources/kernel
  rm -rf ../boom-client/assets/resources/kernel/*
  cargo build --target wasm32-unknown-unknown --release
  find ./target/wasm32-unknown-unknown/release -maxdepth 1 -name "*.wasm" \
  | xargs -I {} sh -c "basename {} | sed 's/\.[^.]*$//'" \
  | xargs -I {} just build_by {}
  # just build_by test

build_by name:
  sh -c "wasm-bindgen target/wasm32-unknown-unknown/release/{{name}}.wasm \
  --out-dir ../boom-client/assets/resources/kernel \
  --target web \
  --typescript"
  sh -c "mv ../boom-client/assets/resources/kernel/{{name}}.js ../boom-client/assets/resources/kernel/{{name}}.mjs"
  # esbuild ../boom-client/assets/kernel/add.js \
  # --bundle \
  # --format=cjs \
  # --platform=browser \
  # --outfile=../boom-client/assets/kernel/add.cjs.js \
  # --external:*.wasm
  # rm -rf ../boom-client/assets/kernel/add.js

set shell := ["bash", "-c"]  # 去掉 -u，防止未赋值时报错

gen_by name:
  mkdir -p ../boom-client/assets/scripts/kernel
  @name="{{name}}"; \
  class_name="${name^}"; \
  outfile="../boom-client/assets/scripts/kernel/${class_name}.ts"; \
  echo "import {assetManager, resources} from 'cc';" > "$outfile"; \
  echo 'import WasmAdapter from "./WasmAdapter";' >> "$outfile"; \
  echo "import init, * as wasm from 'db://assets/resources/kernel/${name}.mjs';" >> "$outfile"; \
  echo '' >> "$outfile"; \
  echo "export default class ${class_name} extends WasmAdapter{" >> "$outfile"; \
  echo '    protected init(wasm_path: string): Promise<any> {' >> "$outfile"; \
  echo '        return init(wasm_path);' >> "$outfile"; \
  echo '    }' >> "$outfile"; \
  echo '    protected target() {' >> "$outfile"; \
  echo '        return wasm;' >> "$outfile"; \
  echo '    }' >> "$outfile"; \
  echo '' >> "$outfile"; \
  echo '    public async load(): Promise<any> {' >> "$outfile"; \
  echo "        return this.load_by_uuid(resources.getDirWithPath('kernel/${name}_bg')[0]?.uuid);" >> "$outfile"; \
  echo '    }' >> "$outfile"; \
  echo '}' >> "$outfile"; \
  echo "export const ${name} = new ${class_name}();" >> "$outfile"; \
  echo "export function load_${name}(callback:(target:any)=>{}):Promise<any>{" >> "$outfile"; \
  echo "    return ${name}.load();" >> "$outfile"; \
  echo '}' >> "$outfile"; \
  echo "✅ 已生成模板到 $outfile"


public:
  mkdir -p ../../rs2ts_cocos/kernel-rs
  find . -mindepth 1 -maxdepth 1 ! -name target -exec cp -r {} ../../rs2ts_cocos/kernel-rs/ \;
  cd ../../rs2ts_cocos/kernel-rs && \
    git add . && \
    git commit -m "feat: nice job." && \
    git push