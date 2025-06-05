install:
  mkdir -p ../boom-client/assets/resources/kernel
  just clean
  cargo build --target wasm32-unknown-unknown --release
  find ./target/wasm32-unknown-unknown/release -maxdepth 1 -name "*.wasm" \
  | xargs -I {} sh -c "basename {} | sed 's/\.[^.]*$//'" \
  | xargs -I {} sh -c "just build_by {}; just gen_by {}"
  # just build_by test

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
  just gen_adaptor_wasm
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

gen_adaptor_wasm:
  mkdir -p ../boom-client/assets/scripts/adaptor
  outfile="../boom-client/assets/scripts/adaptor/Wasm.ts"; \
  echo "/**" > "$outfile"; \
  echo " * @Author : laiyefei" >> "$outfile"; \
  echo " * @Create : $(date +%Y-%m-%d)" >> "$outfile"; \
  echo " * @Desc : wasm 适配层" >> "$outfile"; \
  echo " * @Version : v1.0.0" >> "$outfile"; \
  echo " * @Blog : http://laiyefei.com" >> "$outfile"; \
  echo " * @Github : http://github.com/laiyefei" >> "$outfile"; \
  echo " */" >> "$outfile"; \
  echo "import { _decorator, assetManager, Component, resources } from 'cc';" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "export default abstract class Wasm {" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "    protected abstract init(wasm_path:string):Promise<any>;" >> "$outfile"; \
  echo "    protected abstract target():any;" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "    protected load_by_uuid<T>(uuid:string) : Promise<T>{" >> "$outfile"; \
  echo "        return this.init(assetManager.utils.getUrlWithUuid(uuid)?.replace(/\\.[^/.]+$/, '.wasm')).then(() => {" >> "$outfile"; \
  echo "            return new Promise((resolve) => {" >> "$outfile"; \
  echo "                resolve(this.target());" >> "$outfile"; \
  echo "            });" >> "$outfile"; \
  echo "        });" >> "$outfile"; \
  echo "    }" >> "$outfile"; \
  echo "" >> "$outfile"; \
  echo "    public abstract load():Promise<any>;" >> "$outfile"; \
  echo "}" >> "$outfile"; \
  echo "✅ 已生成 Wasm 适配器到 $outfile"


public:
  mkdir -p ../../rs2ts_cocos/kernel-rs
  find . -mindepth 1 -maxdepth 1 ! -name target -exec cp -r {} ../../rs2ts_cocos/kernel-rs/ \;
  cd ../../rs2ts_cocos/kernel-rs && \
    git add . && \
    git commit -m "feat: nice job." && \
    git push