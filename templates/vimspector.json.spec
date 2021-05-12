{
  "configurations": {
    "cpp:launch": {
      "adapter": "vscode-cpptools",
      "configuration": {
        "name": "cpp",
        "type":    "cppdbg",
        "request": "launch",
        "program": "${fileDirname}/${fileBasenameNoExtension}",
        "args": ["*${ProgramArgs}"],
        "cwd": "${workspaceRoot}",
        "environment": [],
        "externalConsole": true,
        "stopOnEntry": true,
        "MIMode": "gdb",
        "logging": {
          "engineLogging": false
        }
      }
    },
    "cpp:attach": {
      "adapter": "vscode-cpptools",
      "configuration": {
        "name": "cpp",
        "type": "cppdbg",
        "request": "attach",
        "stopOnEntry": true,
        "program": "${fileDirname}/${fileBasenameNoExtension}",
        "MIMode": "gdb"
      }
    },
    "python: Launch": {
      "adapter": "debugpy",
      "configuration": {
        "name": "python",
        "type": "python",
        "python": "python",
        "request": "launch",
        "stopOnEntry": true,
        "console": "externalTerminal",
        "program": "${workspaceRoot}/${mainPyfile}"
      }
    },
    "rust:launch": {
      "adapter": "CodeLLDB",
      "configuration": {
        "name": "rust lldb",
        "type": "lldb",
        "request": "launch",
        "stopOnEntry": true,
        "MIMode": "gdb",
        "program": "${workspaceRoot}/target/debug/${fileWorkspaceFolder}"
      }
    }
  }
}
