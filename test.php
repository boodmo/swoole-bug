#!/usr/bin/env php
<?php

declare(strict_types=1);

interface EntityManagerInterface {
    public function persist(object $entity);
}
class A
{
    public function __construct(/*private ?self $parent = null*/)
    {
    }
}

class EntityManager implements EntityManagerInterface {

    public function persist(object $entity)
    {
        echo "Persisting entity: " . get_class($entity) . "\n";
    }
}
abstract class AbstractDecorator implements EntityManagerInterface {
    protected $wrapped;
    public function persist(object $entity)
    {
        $this->wrapped->persist($entity);
    }
    public function __construct(EntityManager $wrapped)
    {
        $this->wrapped = $wrapped;
    }
}

class EntityManagerDecorator extends AbstractDecorator {
    protected object $proxy;
    protected $wrapped {
        get {
            if (!isset($this->proxy)) {
                $this->proxy = ($this->factory)();
            }
            return $this->proxy;
        }
    }

    public function __construct(private Closure $factory)
    {
    }
}

$em = new EntityManagerDecorator(static fn() => new EntityManager());
$a = new A();
$em->persist($a);
$a1 = new A();
$em->persist($a1);
echo "SCRIPT End!\n";
