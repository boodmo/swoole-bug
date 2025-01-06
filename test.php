#!/usr/bin/env php
<?php

declare(strict_types=1);

interface EntityManagerInterface {
    public function persist(object $entity);
}
class EntityManager /*implements EntityManagerInterface*/ {

    public function persist(object $entity)
    {
        echo "Persisting entity: " . get_class($entity) . "\n";
    }
}
abstract class AbstractDecorator /*implements EntityManagerInterface*/ {
    protected $wrapped;
    public function persist(object $entity)
    {
        $this->wrapped->persist($entity);
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
$a = new stdClass();
$em->persist($a);
$a1 = new stdClass();
$em->persist($a1);
echo "SCRIPT End!\n";
