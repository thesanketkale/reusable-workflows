<?php

declare(strict_types=1);

namespace Fixture\Tests;

use Fixture\Greeter;
use PHPUnit\Framework\TestCase;

final class GreeterTest extends TestCase
{
    public function testGreetReturnsExpectedString(): void
    {
        $greeter = new Greeter();
        $this->assertSame('Hello, World!', $greeter->greet('World'));
    }
}
