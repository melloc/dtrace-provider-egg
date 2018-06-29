# dtrace-provider-egg

This is a module for CHICKEN Scheme to allow writing USDT probes.

An example usage would be:

```scheme
(use dtrace-provider)

(define provider (usdt/create-provider "chicken" "scheme"))
(define probe (usdt/create-probe "is" "awesome" '("char *")))
(usdt/provider-add-probe provider probe)
(usdt/provider-enable provider)
(usdt/fire-probe probe '("hello"))
```
