# Word list attribution

`valid_guesses.txt` was derived by filtering `words_alpha.txt` from the
[dwyl/english-words](https://github.com/dwyl/english-words) project down to
lowercase, five-letter, purely alphabetic entries (the Unlicense / public domain).

`answers.txt` is a hand-curated list of common five-letter English words
(written for this project) that was verified to be present in the source list,
then shuffled once with a fixed seed. **Append new words to the end only**:
the daily challenge index is `(challengeNumber - 1) % answers.length`, so
reordering or deleting entries would change past and future puzzles.
`valid_guesses.txt` never repeats an answer word (answers are always accepted
as guesses automatically).
