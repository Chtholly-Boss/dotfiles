# Environment Setup on New Machine
## Agent
> If you are already an agent, ignore this part

Install nodejs:

```sh
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 22
```

Network Issue -> try:

```sh
apt-get update && apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=22
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update && apt-get install -y nodejs
npm config set registry https://registry.npmmirror.com
```

Then use npm: `npm i -g @openai/codex`

or if using claude code: `npm i -g @anthropic-ai/claude-code; claude update`

## VScode

## Others
- apt install -y unzip curl ripgrep rsync git vim tmux
- curl -LsSf https://astral.sh/uv/install.sh | sh

