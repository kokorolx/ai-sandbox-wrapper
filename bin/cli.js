#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const args = process.argv.slice(2);
const command = args[0];
const packageRoot = path.resolve(__dirname, '..');

function showHelp() {
  console.log(`
🔒 AI Sandbox Wrapper

Usage:
  npx @kokorolx/ai-sandbox-wrapper <command>

Commands:
  setup     Run interactive setup (configure workspaces, select tools)
  help      Show this help message

Examples:
  npx @kokorolx/ai-sandbox-wrapper setup

Documentation: https://github.com/kokorolx/ai-sandbox-wrapper
`);
}

function runSetup() {
  const setupScript = path.join(packageRoot, 'setup.sh');
  
  if (!fs.existsSync(setupScript)) {
    console.error('❌ Error: setup.sh not found at', setupScript);
    console.error('This may indicate a corrupted installation.');
    process.exit(1);
  }

  try {
    fs.chmodSync(setupScript, '755');
  } catch (err) {
    /* Windows doesn't support chmod */
  }

  const child = spawn('bash', [setupScript], {
    cwd: packageRoot,
    stdio: 'inherit',
    env: {
      ...process.env,
      AI_SANDBOX_ROOT: packageRoot
    }
  });

  child.on('error', (err) => {
    if (err.code === 'ENOENT') {
      console.error('❌ Error: bash not found. Please install bash to run setup.');
      console.error('  macOS/Linux: bash is usually pre-installed');
      console.error('  Windows: Use WSL2 or Git Bash');
    } else {
      console.error('❌ Error running setup:', err.message);
    }
    process.exit(1);
  });

  child.on('close', (code) => {
    process.exit(code || 0);
  });
}

switch (command) {
  case 'setup':
  case undefined:
    runSetup();
    break;
  case 'help':
  case '--help':
  case '-h':
    showHelp();
    break;
  default:
    console.error(`❌ Unknown command: ${command}`);
    showHelp();
    process.exit(1);
}
