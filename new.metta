!(bind! &database (new-space))
!(bind! table ((A (True True False False)) (B (False False True False)) (C (False False False False)) (D (True True True True)) (Output (True True False False))))


(= (zip $list1 $list2)
   (if (or (==  $list1 ()) (== $list2 ())) 
   () 
   (let*
          (
              (($xhd $xtl) (decons-atom $list1))
              (($yhd $ytl) (decons-atom $list2))
              ($res (zip $xtl $ytl))
            )
            (cons-atom ($xhd $yhd) $res)
        )
    )
)
!(add-reduct &self ((superpose table) (superpose table)) )
!(add-reduct &database(let $atom (match &self ($x (Output $y)) ($x (Output $y))) $atom))



(= (marginalProb $list $value)
    (/ (foldl-atom $list 0 $acc $x (if (== $x $value) (+ 1 $acc) $acc)) (* (size-atom $list) 1.0))
)
(= (helper ($x $y) ($a $b)) 
    (if (and (== $x $a) (== $y $b))
        1
        0
    )
)

(= (jointProb $list ($x $y))
    (/ (foldl-atom $list 0 $acc $pairs (+ $acc (helper $pairs ($x $y)))) (* (size-atom $list) 1.0))
)
; !(jointProb ((1 2) (3 5) (1 2)) (1 2))

(= (unique_helper $list) (collapse (unique (superpose $list))))

; !(unique_helper ((1 2) (1 2) 1))

(= (calcMI_helper ($margin1 $margin2 $jointProb))
    (* $jointProb (log-math 2 (/ $jointProb (* (* $margin1 $margin2) 1.0))))
)
(= (calcMI_helper2 $list) (foldl-atom $list 0 $acc $each (+ $each $acc)))

; !(calcMI_helper (0.5 0.5 0.5))
(= (calcMI) 
    (let $pairs 
        (match &database (($label1 $values1) ($label2 $values2)) 
            (if (== $label1 $label2) (empty) (The correlation between $label1 "and" $label2 is 
                (calcMI_helper2 
                    (collapse 
                        (let*(
                            ($zippedAll (zip $values1 $values2))
                            ($zippedUnique (unique_helper $zippedAll))
                            ($each (superpose $zippedUnique))

                            ($jointProb (jointProb $zippedAll $each))
                            ($each_ele1 (index-atom $each 0))
                            ($each_ele2 (index-atom $each 1))
                            ($margin1 (marginalProb $values1 $each_ele1))
                            ($margin2 (marginalProb $values2 $each_ele2))
                            (() (println! ("zipped all" $zippedAll "zipped unique" $zippedUnique "each" $each "label1": $label1 "label2": $label2)))
                            ($answer (calcMI_helper ($margin1 $margin2 $jointProb)))
                            (() (println! ("$margin1" $margin1 "$margin2" $margin2 "Joint" $jointProb)))
                            )
                            $answer
                        )
                    )
                )
            ))
        )
        $pairs
    ) 
)

!(calcMI)
; !(match &database ((A $x) (Output $y)) ($x $y))
