# encoding: utf-8

DUMMY_APP_PATH = File.expand_path('../../dummy', __FILE__)

DUMMY_ZEUS_LOG_PATH = File.expand_path('../dummy_zeus.log', __FILE__)

ZEUS_LOG_LINES = {
  :commands => [
    "\e[32mzeus destroy (alias: d)\e[K\e[0m\n",
    "\e[32mzeus server (alias: s)\e[K\e[0m\n",
    "\e[32mzeus console (alias: c)\e[K\e[0m\n",
    "\e[32mzeus dbconsole\e[K\e[0m\n",
    "\e[32mzeus runner (alias: r)\e[K\e[0m\n",
    "\e[32mzeus generate (alias: g)\e[K\e[0m\n",
    "\e[32mzeus rake\e[K\e[0m\n",
    "\e[32mzeus test (alias: rspec, testrb)\e[K\e[0m\n"
  ],
  :processes => [
    "\e[32mboot\e[K\e[0m\n",
    "\e[33m└── \e[32mdefault_bundle\e[K\e[0m\n",
    "\e[33m    \e[33m├── \e[32mdevelopment_environment\e[K\e[0m\n",
    "\e[33m    \e[33m│   \e[33m└── \e[32mprerake\e[K\e[0m\n",
    "\e[33m    \e[33m└── \e[32mtest_environment\e[K\e[0m\n",
    "\e[33m    \e[33m    \e[33m└── \e[32mtest_helper\e[K\e[0m\n"
  ],
  :all => [
    "\e[4m\e[32m[ready] \e[31m[crashed] \e[34m[running] \e[35m[connecting] \e[33m[waiting]\e[K\e[0m\n",
    "\e[32mboot\e[K\e[0m\n",
    "\e[33m└── \e[32mdefault_bundle\e[K\e[0m\n",
    "\e[33m    \e[33m├── \e[32mdevelopment_environment\e[K\e[0m\n",
    "\e[33m    \e[33m│   \e[33m└── \e[32mprerake\e[K\e[0m\n",
    "\e[33m    \e[33m└── \e[32mtest_environment\e[K\e[0m\n",
    "\e[33m    \e[33m    \e[33m└── \e[32mtest_helper\e[K\e[0m\n",
    "\e[K\n",
    "\e[4mAvailable Commands: \e[33m[waiting] \e[31m[crashed] \e[32m[ready]\e[K\e[0m\n",
    "\e[32mzeus destroy (alias: d)\e[K\e[0m\n",
    "\e[32mzeus server (alias: s)\e[K\e[0m\n",
    "\e[32mzeus console (alias: c)\e[K\e[0m\n",
    "\e[32mzeus dbconsole\e[K\e[0m\n",
    "\e[32mzeus runner (alias: r)\e[K\e[0m\n",
    "\e[32mzeus generate (alias: g)\e[K\e[0m\n",
    "\e[32mzeus rake\e[K\e[0m\n",
    "\e[32mzeus test (alias: rspec, testrb)\e[K\e[0m\n"
  ]
}