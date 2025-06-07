install:
  just clean
  just publish

publish:
  mkdir -p ../boom-client/assets/resources/kernel
  just release
  find ./target/wasm32-unknown-unknown/release -maxdepth 1 -name "*.wasm" \
  | xargs -I {} sh -c "basename {} | sed 's/\.[^.]*$//'" \
  | xargs -I {} sh -c "just build_by {}; just gen_by {}"

build:
  cargo build --target wasm32-unknown-unknown

release:
  cargo build --target wasm32-unknown-unknown --release

clean:
  rm -rf ../boom-client/assets/resources/kernel/*
  rm -rf ../boom-client/assets/scripts/kernel/*
  cargo clean
  

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
  echo "/**" > "$outfile"; \
  echo " * @Author : laiyefei" >> "$outfile"; \
  echo " * @Create : $(date +%Y-%m-%d)" >> "$outfile"; \
  echo " * @Desc : 业务逻辑：${class_name}" >> "$outfile"; \
  echo " * @Version : v1.0.0" >> "$outfile"; \
  echo " * @Blog : http://laiyefei.com" >> "$outfile"; \
  echo " * @Github : http://github.com/laiyefei" >> "$outfile"; \
  echo " */" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "import { resources } from 'cc';" >> "$outfile"; \
  echo "import Wasm from '../adaptor/Wasm';" >> "$outfile"; \
  echo "import init, * as wasm from 'db://assets/resources/kernel/${name}.mjs';" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "export default class ${class_name} extends Wasm {" >> "$outfile"; \
  echo "    private static _instance: ${class_name} = new ${class_name}();" >> "$outfile"; \
  echo "    public static get_instance(): ${class_name} {" >> "$outfile"; \
  echo "        return this._instance;" >> "$outfile"; \
  echo "    }" >> "$outfile"; \
  echo "    protected init(wasm_path: string): Promise<any> {" >> "$outfile"; \
  echo "        return init(wasm_path);" >> "$outfile"; \
  echo "    }" >> "$outfile"; \
  echo "    protected target() {" >> "$outfile"; \
  echo "        return wasm;" >> "$outfile"; \
  echo "    }" >> "$outfile"; \
  echo "    public async load(): Promise<any> {" >> "$outfile"; \
  echo "        return this.load_by_uuid(resources.getDirWithPath('kernel/${name}_bg')[0]?.uuid);" >> "$outfile"; \
  echo "    }" >> "$outfile"; \
  echo "}" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "export const ${name} = ${class_name}.get_instance();" >> "$outfile"; \
  echo "export function load_${name}(callback: (target: any) => {}): Promise<any> {" >> "$outfile"; \
  echo "    return ${name}.load();" >> "$outfile"; \
  echo "}" >> "$outfile"; \
  echo "✅ 已生成模板到 $outfile"


public:
  # rm -rf ../../rs2ts_cocos/kernel-rs
  mkdir -p ../../rs2ts_cocos/kernel-rs
  cp .justfile ../../rs2ts_cocos/kernel-rs/
  echo "[workspace]" > ../../rs2ts_cocos/kernel-rs/Cargo.toml
  echo 'members = ["test"]' >> ../../rs2ts_cocos/kernel-rs/Cargo.toml
  find . -mindepth 1 -maxdepth 1 -name test -exec cp -r {} ../../rs2ts_cocos/kernel-rs/ \;
  cd ../../rs2ts_cocos/kernel-rs && \
    git add . && \
    git commit -m "feat: nice job." && \
    git push
