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

class UnitOfWork
{
    public function __construct(private readonly EntityManagerInterface $em)
    {
    }

    public function persist(object $entity)
    {
        echo "Persisting entity: " . get_class($entity) . "\n";
    }
}
class EntityManager implements EntityManagerInterface {

    private UnitOfWork $unitOfWork;
    public function __construct()
    {
        $this->unitOfWork        = new UnitOfWork($this);
    }

    public function persist(object $entity)
    {
        $this->unitOfWork->persist($entity);
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
            $context = $this->getContext();
            if (! isset($context[self::class]) || ! $context[self::class] instanceof EntityManagerInterface) {
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
