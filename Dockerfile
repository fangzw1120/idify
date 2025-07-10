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
