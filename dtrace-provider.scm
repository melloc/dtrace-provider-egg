(require-library lolevel posix)

(module dtrace-provider
        (usdt/create-provider
          usdt/create-probe
          usdt/provider-add-probe
          usdt/provider-remove-probe
          usdt/provider-enable
          usdt/provider-disable
          usdt/fire-probe)
        (import scheme chicken lolevel foreign posix)
        (foreign-declare "#include \"libusdt/usdt.h\"")

(define-foreign-type usdt/provider_t "usdt_provider_t")
(define-foreign-type usdt/probedef_t "usdt_probedef_t")

(define usdt_provider_add_probe
  (foreign-lambda int "usdt_provider_add_probe"
                  (c-pointer usdt/provider_t) (c-pointer usdt/probedef_t)))

(define usdt_provider_remove_probe
  (foreign-lambda int "usdt_provider_remove_probe"
                  (c-pointer usdt/provider_t) (c-pointer usdt/probedef_t)))

(define usdt_provider_enable
  (foreign-lambda int "usdt_provider_enable"
                  (c-pointer usdt/provider_t)))

(define usdt_provider_disable
  (foreign-lambda int "usdt_provider_disable"
                  (c-pointer usdt/provider_t)))

(define usdt_create_probe
  (foreign-lambda (c-pointer usdt/probedef_t) "usdt_create_probe"
                  nonnull-c-string nonnull-c-string size_t pointer-vector))

(define usdt_errstr
  (foreign-lambda c-string "usdt_errstr" (c-pointer usdt/provider_t)))

(define str-pointer
  (foreign-lambda* (c-pointer void) ((c-string s)) "C_return(s);"))

(define (type->assertion t)
  (cond
    [(string=? t "char *") string?]
    [(string=? t "int") integer?]
    [(string=? t "float") flonum?]
    [else (abort "unrecognized type")]))

(define (strlist->assertions l)
  (map type->assertion l))

(define (strlist->strarray l)
  (apply pointer-vector (map str-pointer l)))

(define usdt/create-provider
  (foreign-lambda (c-pointer usdt/provider_t) "usdt_create_provider"
                  nonnull-c-string nonnull-c-string))

(define (usdt/create-probe name module args)
  (let ([argc (length args)]
        [assertions (strlist->assertions args)]
        [argv (strlist->strarray args)])
    (usdt_create_probe name module argc argv)))

(define (usdt/provider-add-probe provider probedef)
  (when (not (= (usdt_provider_add_probe provider probedef) 0))
    (abort (usdt_errstr provider))))

(define (usdt/provider-remove-probe provider probedef)
  (when (not (= (usdt_provider_remove_probe provider probedef) 0))
    (abort (usdt_errstr provider))))

(define (usdt/provider-enable provider)
  (when (not (= (usdt_provider_enable provider) 0))
    (abort (usdt_errstr provider))))

(define (usdt/provider-disable provider)
  (when (not (= (usdt_provider_disable provider) 0))
    (abort (usdt_errstr provider))))

(define usdt_fire_probe
  (foreign-lambda* void (((c-pointer usdt/probedef_t) pd)
                         (size_t vc)
                         (pointer-vector pv))
                   "usdt_fire_probe(pd->probe, vc, pv);"))

(define (usdt/fire-probe probedef args)
  (let ([argc (length args)]
        [argv (strlist->strarray args)])
        (usdt_fire_probe probedef argc argv)))
 
)
