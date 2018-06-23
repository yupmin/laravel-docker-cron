# Laravel docker cron

## How to use

```bash
git clone https://github.com/yupmin/laravel-docker-cron
cd laravel-docker-cron
laravel new
```

Install schedule list

```bash
composer require hmazter/laravel-schedule-list
```

## Example

```bash
php artisan make:command HelloCron
```

Edit app/Console/Commands/HelloCron.php

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class HelloCron extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'hello:cron';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Hello cron!!';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->info('Hello Cron!!');

        return 1;
    }
}
```

Edit app/Console/Kernel.php

```php
    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command(HelloCron::class, ['--no-ansi'])
            ->everyMinute()
            ->appendOutputTo(storage_path('logs/cron.log'))
        ;
    }
```
