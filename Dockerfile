# 使用 node:18-alpine 作为基础镜像，用于构建前端项目
FROM node:18-alpine AS builder

# 启用 corepack 并准备一个兼容的 pnpm 版本
RUN corepack enable && corepack prepare pnpm@8.6.12 --activate && \
    apk add --no-cache libc6-compat python3 make g++

# 设置工作目录
WORKDIR /app

# 为了更好地利用 Docker 缓存，先只复制构建依赖所需的文件
COPY pnpm-workspace.yaml ./
COPY package.json pnpm-lock.yaml ./
COPY packages/common/package.json ./packages/common/
COPY packages/mobile/package.json ./packages/mobile/
COPY packages/web/package.json ./packages/web/

# 安装项目依赖
RUN pnpm install

# 复制所有项目文件
COPY . .

# 构建 web 项目
RUN pnpm --filter @idify/web run build

# 使用 nginx:alpine 作为最终镜像，用于运行构建好的项目
FROM nginx:alpine

# 复制 nginx 配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 复制构建好的前端文件到 nginx 的 web 根目录
COPY --from=builder /app/packages/web/dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 nginx 服务
CMD ["nginx", "-g", "daemon off;"]


# docker image push to remote hub
# docker login
# docker tag idify:latest forisfang/idify:20250710
# docker push forisfang/idify:20250710

# docker push forisfang/idify:tagname

# mac 宿主机安装 corepack pnpm install (Install project dependencies using corepack.)
# cp /Users/forisfang/project/github/idify/node_modules/.pnpm/@zhbhun+background-removal@1.0.8/node_modules/@zhbhun/background-removal/dist/*  packages/web/public/background-removal/
#  1. 本地安装：pnpm 将所有依赖项安装在项目根目录下的 node_modules 文件夹中。
#    2. `.pnpm` 虚拟存储：pnpm 的一个核心特性是，它不会像 npm 或 Yarn 那样将所有依赖项平铺在 node_modules 的根目录下。相反，它在 node_modules/.pnpm
#       目录中创建了一个“虚拟存储”。
#    3. 全局内容可寻址存储：实际的包文件只在您的计算机上存储一次，位于一个全局的内容可寻址存储中（根据您之前的日志，它位于 /Users/forisfang/Library/pnpm/store/v3）。
#    4. 硬链接：pnpm 通过硬链接（Hard Links）将全局存储中的文件链接到您项目本地的 node_modules/.pnpm 目录中，然后再链接到 node_modules 的顶层。