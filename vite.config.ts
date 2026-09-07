import { defineConfig } from 'vite';

// BASE_PATH wird vom GitHub-Pages-Workflow gesetzt (z. B. "/repo-name/").
export default defineConfig({
  base: process.env.BASE_PATH ?? '/',
  build: { target: 'es2022' },
});
