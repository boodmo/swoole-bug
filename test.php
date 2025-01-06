#!/usr/bin/env php
<?php

declare(strict_types=1);

class A
{
    public function __construct(private ?self $parent = null)
    {
    }
}

class EntityManager {
    public function persist(object $entity)
    {
        echo "Persisting entity: " . get_class($entity) . "\n";
    }
}
abstract class AbstractDecorator {
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
    protected ArrayObject $storage;
    protected $wrapped {
        get {
            $context = $this->getContext();
            if (! isset($context[self::class]) || ! $context[self::class] instanceof EntityManager) {
                $context[self::class] = ($this->emCreatorFn)();
            }
            return $context[self::class];
        }
    }

    public function __construct(private Closure $emCreatorFn)
    {
        $this->storage = new ArrayObject();
    }

    private function getContext() : ArrayObject
    {
        /** @psalm-var Co\Context|array */
        return $this->storage;
    }
}

$em = new EntityManagerDecorator(static fn() => new EntityManager());
$a = new A();
$em->persist($a);
$a1 = new A($a);
$em->persist($a1);
echo "SCRIPT End!\n";
