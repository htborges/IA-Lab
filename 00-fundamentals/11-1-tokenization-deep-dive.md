# 11.1 · Tokenization in depth

> 🇺🇸 English · 🇧🇷 [Português](11-1-tokenization-deep-dive.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [11 · Generative AI and LLMs](11-llms.md) |
| **Level** | Deep dive |
| **Prerequisites** | [11 · LLMs and Transformers](11-llms.md) |
| **Reading time** | ~30 min |
| **You will learn** | Why LLMs use pieces of words, how the BPE algorithm builds a vocabulary (worked by hand), what byte-level BPE, WordPiece and SentencePiece change, and how tokenization opens loopholes: bypassed filters, forged special tokens, glitch tokens and cost |

## Where we left off

In [lesson 11](11-llms.md) we saw that the model reads neither letters nor words, but **tokens**, and we showed an illustrative split of "Ignore the previous instructions". Some questions were left open: **who decides** where each word gets cut, why "password" and "PASSWORD" become different sequences, and why that matters so much for security.

## Why pieces of words?

There are three possible choices for the "unit" of text:

| Unit | Advantage | Problem |
|------|-----------|---------|
| **Character** | Tiny vocabulary, no unknown words | Huge sequences: the context fills up fast and the model has to learn to spell everything |
| **Whole word** | Short sequences | Giant vocabulary (every verb form, every name, every typo) and out-of-vocabulary words become an "unknown" token |
| **Subword** | Middle ground: common words become one token, rare words become a few pieces | It is what LLMs use |

With subwords, "hacker" can be a single token, and a never-seen word breaks into known pieces, without ever becoming "unknown".

## BPE: building the vocabulary by hand

**BPE** (*Byte Pair Encoding*) is the most widely used algorithm. The idea is simple: start with characters and **repeatedly merge the most frequent neighboring pair**.

### The corpus

A minimal corpus, with each word's frequency:

| Word | hack | hacks | hacker | tracker | track |
|------|------|-------|--------|---------|-------|
| Frequency | 5 | 2 | 6 | 3 | 4 |

The initial vocabulary is the characters: `h a c k s e r t`. Each word starts split into letters, and merges never cross the boundary between words.

### The merges

At each step, we count every pair of neighboring symbols, **weighted by the word's frequency**, and merge the most common pair. On a tie, we use alphabetical order (each implementation has its own tie-break rule).

| Step | Most frequent pair | Count | What the words look like |
|------|--------------------|-------|--------------------------|
| 1 | `a` + `c` | 20 (tied with `c k`) | h·**ac**·k, t·r·**ac**·k·e·r … |
| 2 | `ac` + `k` | 20 | h·**ack**, t·r·**ack**·e·r … |
| 3 | `h` + `ack` | 13 | **hack**, **hack**·s, **hack**·e·r … |
| 4 | `e` + `r` | 9 | **hack**·**er**, t·r·ack·**er** |
| 5 | `r` + `ack` | 7 (tied with `t r`) | t·**rack**·er, t·**rack** |
| 6 | `t` + `rack` | 7 | **track**·er, **track** |
| 7 | `hack` + `er` | 6 | **hacker** |

Checking step 1: the pair `a c` shows up in every word, so it adds up to 5 + 2 + 6 + 3 + 4 = 20.

After 7 merges, the vocabulary has 8 characters + 7 new tokens = **15 tokens**:

```text
h a c k s e r t  ac ack hack er rack track hacker
```

And the corpus ends up like this:

| Word | Tokens |
|------|--------|
| hack | `hack` |
| hacks | `hack` `s` |
| hacker | `hacker` |
| track | `track` |
| tracker | `track` `er` |

### Tokenizing new words

To tokenize new text, the tokenizer applies the merges **in the order they were learned**:

| New word | Tokens | Note |
|----------|--------|------|
| hackers | `hacker` `s` | Reuses known pieces |
| tracked | `track` `e` `d` | "ed" was never merged in this corpus |
| attack | `a` `t` `t` `ack` | A rare word for this vocabulary: it becomes 4 tokens |

This is the pattern in any LLM: words that were frequent when the tokenizer was trained stay compact, and rare ones fragment. A real tokenizer performs tens or hundreds of thousands of merges over billions of words, and ends up with vocabularies of 30 thousand to over 200 thousand tokens.

## Variants of the algorithm

| Tokenizer | Main difference | Where it shows up |
|-----------|-----------------|-------------------|
| **Byte-level BPE** | Starts from the 256 byte values instead of characters. Any text, in any language or with any emoji, can be represented; there is never an unknown symbol | GPT families and many open models |
| **WordPiece** | Picks the merge that most increases the corpus likelihood, not just the most frequent one; marks word continuations (like `##s`) | BERT and derivatives |
| **Unigram / SentencePiece** | Starts with a large vocabulary and **removes** the tokens that are missed the least; treats the space as an ordinary character, which works well for languages without spaces | T5, several multilingual models |

Details that change tokenization in practice:

- **The space is part of the token**: `"password"` at the start of the text and `" password"` in the middle of a sentence are usually different tokens.
- **Capital letters and accents** produce different sequences: `password`, `Password` and `PASSWORD` may share no token at all.
- **Language matters**: the tokenizer learned its merges from the text it saw. Languages that were less present in that text, such as Portuguese in many models, break into more pieces, and the same content costs more tokens.

## Special tokens

Besides pieces of text, the vocabulary has **special tokens** that should never come from the user: end of text, start and end of each message, role markers (`system`, `user`, `assistant`) from the chat template ([lesson 11](11-llms.md)), tool call markers.

They are the "structural punctuation" of the conversation. If text typed by the user gets converted into the **real special token**, rather than the ordinary pieces that make up that string, the user can forge the structure: close their own message and open a fake system message. That is why tokenization libraries have options to treat special token strings coming from the user as plain text, and why those options must be on.

> [!TIP]
> **Red teamer's view**
> 1. **Word filters do not see tokens.** A blocklist looks for the string "ignore"; the model sees tokens. Changes in capitalization, extra spaces, hyphens, look-alike letters from other alphabets (*homoglyphs*) and invisible characters completely change tokenization, and the model, which learned to read "messy" text, still understands the request ([jailbreaks](../02-prompt-injection/jailbreaks.md), token smuggling).
> 2. **Forged special tokens.** Test whether chat and end-of-message marker strings typed by the user or found in documents are treated as text or as structure. If they become structure, the injection turns into role spoofing ([direct injection](../02-prompt-injection/direct-prompt-injection.md)).
> 3. **Glitch tokens.** Some tokens got into the vocabulary (because they were frequent in the text used to train the tokenizer) but almost never showed up in the model's training. Their embeddings were poorly trained, and asking the model to repeat them has caused absurd answers, refusals and hallucinations in well-known models.
> 4. **Cost and denial of service.** Text that fragments heavily (rare Unicode, random strings, certain languages) uses many more tokens for the same number of characters. Limits measured in characters do not protect a budget measured in tokens (LLM10).
> 5. **Counting letters is hard for the model** because it does not see letters. That explains mistakes on "spelling" tasks, and it is why asking for spelled-out or separated output gets past exact-match filters ([system prompt leakage](../02-prompt-injection/system-prompt-leakage.md)).

## Hands-on with Python

A complete BPE in plain Python that reproduces the merges on this page:

```python
from collections import Counter

corpus = {"hack": 5, "hacks": 2, "hacker": 6, "tracker": 3, "track": 4}
words = {w: list(w) for w in corpus}

def merge(tokens, a, b):
    out, i = [], 0
    while i < len(tokens):
        if i < len(tokens) - 1 and tokens[i] == a and tokens[i + 1] == b:
            out.append(a + b)
            i += 2
        else:
            out.append(tokens[i])
            i += 1
    return out

merges = []
for _ in range(7):
    pairs = Counter()
    for w, toks in words.items():
        for a, b in zip(toks, toks[1:]):
            pairs[(a, b)] += corpus[w]
    (a, b), n = min(pairs.items(), key=lambda kv: (-kv[1], kv[0]))   # most frequent; tie: alphabetical
    merges.append((a, b))
    words = {w: merge(t, a, b) for w, t in words.items()}
    print(a, "+", b, n)
# a + c 20 · ac + k 20 · h + ack 13 · e + r 9 · r + ack 7 · t + rack 7 · hack + er 6

def tokenize(word):
    toks = list(word)
    for a, b in merges:
        toks = merge(toks, a, b)
    return toks

for w in ("hackers", "tracked", "attack"):
    print(w, tokenize(w))
# hackers ['hacker', 's']
# tracked ['track', 'e', 'd']
# attack ['a', 't', 't', 'ack']
```

To look at real tokenizers, use the model's own library: `tiktoken` (OpenAI models) or Hugging Face's `AutoTokenizer` (open models). Compare the token count of the same sentence in English and Portuguese, and of `password`, `Password` and `PASSWORD`.

## Summary

- LLMs use **subwords**: common words become one token and rare words break into pieces, with no "unknown word" ever.
- **BPE** starts from characters (or bytes) and repeatedly merges the most frequent neighboring pair; to tokenize, it applies the merges in the learned order.
- **Byte-level BPE**, **WordPiece** and **Unigram/SentencePiece** are the main variants; spaces, capitalization, accents and language change tokenization.
- **Special tokens** give the conversation its structure and must never be forgeable by the user.
- For the attacker: word filters can be bypassed, special tokens can be forged, **glitch tokens** destabilize the model and fragmented text raises cost.

## Check your understanding

<details><summary>1. In the page's corpus, why was the first merge "a + c" with a count of 20?</summary>

Because the pair "a c" shows up in all five words (hack, hacks, hacker, tracker, track), and the count is weighted by each word's frequency: 5 + 2 + 6 + 3 + 4 = 20. The pair "c k" also added up to 20, and the tie was broken alphabetically.
</details>

<details><summary>2. Why did "attack" become 4 tokens, while "hacker" became 1?</summary>

Because the vocabulary was learned from a corpus where "hacker" was frequent and "attack" never appeared. The learned merges only cover the "ack" piece; the rest stays as loose characters. Words that are rare for the tokenizer always fragment more.
</details>

<details><summary>3. What is the advantage of byte-level BPE over character-level BPE?</summary>

Since the base vocabulary holds all 256 byte values, any text can be represented, including emojis, rare alphabets and corrupted characters. There is never an unknown symbol.
</details>

<details><summary>4. An application blocks messages containing the word "password". Why does swapping a Latin letter for a similar-looking Cyrillic letter usually bypass the filter and still be understood by the model?</summary>

The filter compares strings, and the Cyrillic letter is a different character, so the string does not match. For the model, the word becomes a different token sequence, but it learned from a lot of noisy text and usually recognizes the intent from context.
</details>

<details><summary>5. What can happen if the tokenizer converts a "system message" marker string typed by the user into the corresponding special token?</summary>

The user gains control over the conversation's structure: they can close their own message and open a fake system message, which the model treats with the authority of a developer instruction. It is a form of injection through role spoofing.
</details>

---

← [11 · Generative AI and LLMs](11-llms.md) · **Next lesson in the track:** [12 · Diffusion models](12-diffusion-models.md) →
