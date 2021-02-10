{
    "py_projectionist/*.py": {
        "dispatch": "PYTHONPATH={project} python tests/{dirname}/test_{basename}.py",
        "alternate": "tests/{dirname}/test_{basename}.py",
        "make": "make -f Makefile"
    },
    "tests/*.py": {
        "dispatch": "PYTHONPATH={project} python {file}",
        "make": "make -f Makefile",
        "template": [
            "#!/usr/bin/env python",
            "# -*- coding: utf-8 -*-",
            "# {}测试代码模板..."
        ]
    }
}
