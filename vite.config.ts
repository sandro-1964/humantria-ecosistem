import path from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@/components': path.resolve(__dirname, 'src/ui/lovable/components'),
      '@/contexts': path.resolve(__dirname, 'src/ui/lovable/contexts'),
      '@/hooks': path.resolve(__dirname, 'src/ui/lovable/hooks'),
      '@/lib': path.resolve(__dirname, 'src/ui/lovable/lib'),
      '@': path.resolve(__dirname, 'src'),
    },
  },
})
