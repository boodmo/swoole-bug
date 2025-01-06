#!/usr/bin/env php
<?php

declare(strict_types=1);

interface EntityManagerInterface {
    public function persist(object $entity);
}
class A
{
    public function __construct(private ?self $parent = null)
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
    protected ArrayObject $storage;
    /**
     * phpcs:disable PSR2.Classes.PropertyDeclaration.ScopeMissing, PSR2.Classes.PropertyDeclaration.Multiple,
     * phpcs:disable Generic.WhiteSpace.ScopeIndent.IncorrectExact, WebimpressCodingStandard.Methods.LineAfter.BlankLinesAfter
     * phpcs:disable WebimpressCodingStandard.WhiteSpace.BlankLine.BlankLine
     * phpcs:disable SlevomatCodingStandard.Commenting.DocCommentSpacing.IncorrectLinesCountBetweenDescriptionAndAnnotations
     * @var EntityManagerInterface
     */
    protected $wrapped {
        get {
            if (! isset($this->storage[self::class]) || ! $this->storage[self::class] instanceof EntityManagerInterface) {
                $this->storage[self::class] = ($this->emCreatorFn)();
            }
            return $this->storage[self::class];
        }
    }

    public function __construct(private Closure $emCreatorFn)
    {
        $this->storage = new ArrayObject();
    }
}

$em = new EntityManagerDecorator(static fn() => new EntityManager());
$a = new A();
$em->persist($a);
$a1 = new A($a);
$em->persist($a1);
echo "SCRIPT End!\n";
