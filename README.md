# ECOOP23 Artefact README

> # *Designing Asynchronous Multiparty Protocols<br/>with Crash-Stop Failures*

<br/>

Our paper presents **Teatrino**, a code generation toolchain that utilises
asynchronous *multiparty session types* (MPST) with *crash-stop* semantics to
support failure handling protocols.
The tool generates Scala code that uses the **Effpi** concurrency library.

The artifact submission comprises the following:

- the submission document, and
- the main artifact, this Docker image, containing source code of **Teatrino**,
    our tool, and our extended **Effpi** concurrency library.

This overview describes the steps to use **Teatrino**, run our benchmarking
suite, and provides an outline of the contents of this Docker image.

1. **[Quick Start Guide](#1-quick-start-guide)**
    - [1.1](#11-example-protocols) Example Protocols
    - [1.2](#12-generating-scala-code-via-teatrino) Generating Scala Code via **Teatrino**
    - [1.3](#13-running-generated-scala-code) Running Generated Scala Code
2. **[Benchmarking](#2-benchmarking)**
3. **[Artefact Layout](#3-artefact-layout)**

---
---

## 1. Quick Start Guide

We provide commands and scripts that will allow you to both quickly generate
code from the examples in the paper, and compile and execute that generated
code.

---

### 1.1 Example Protocols

All example protocols listed in the paper can be found in the
`/home/mpst/examples/` directory.

Each example file name begins with the variant identifier, followed by the name
of the example, and ends with an indication of which roles are reliable in the
protocol.

For example, `example/a_PingPongAll.nuscr` corresponds to Variant (a) in the
paper, and all roles are reliable. Similarly, `example/h_OAuthSA.nuscr`
corresponds to Variant (h) in the paper, and roles S and A are reliable.

---

### 1.2 Generating Scala Code via Teatrino

To generate Scala code from a given Scribble file, `Protocol.nuscr`, it suffices
to run the command:

```bash
$ Teatrino -e -f Protocol.nuscr
```

This will generate a new file: `scala/Protocol.scala`.

For example, running

```bash
$ Teatrino -e -f examples/Sec6_SimpleLogger.nuscr
```
will result in the output:
```
Input file name: examples/Sec6_SimpleLogger.nuscr
Output Directory: scala/
```
and will produce `scala/Sec6_SimpleLogger.nuscr`, which contains code
corresponding to Fig. 12 in the paper.

Other optional flags are available and can be seen by running:

```bash
$ Teatrino -h
```

To generate code for all protocols in `examples/`, you can run the command:
```
$ ./genAll.sh
```
The resulting generated code can be found in `scala/` directory.

---

### 1.3 Running Generated Scala Code

To compile and run generated Scala code, e.g. `scala/Protocol.scala`, run the
`runScala.sh` script:

```bash
$ ./runScala.sh scala/Protocol.scala
```

This will run the Scala build tool `sbt` using the provided `build.sbt`
configuration file. Generated code includes a number of print statements that
are designed to illustrate the communications behaviour of the given example.
For example, for `a_PingPongAll.nuscr` the generated code may produce the
following output:
```
-- Q recursing; t = RecT0
-- Q entering recursion body; t = RecT0
-- Q expecting Ping on c0 (effpi.channel.QueueChannel@1981978917)
-- Q received Ping on c0 (effpi.channel.QueueChannel@1981978917)
-- Q sending Pong on c1 (effpi.channel.QueueChannel@1942478618)
-- P sent Ping on c0 (effpi.channel.QueueChannel@1981978917)
-- P expecting Pong on c1 (effpi.channel.QueueChannel@1942478618)
-- P received Pong on c1 (effpi.channel.QueueChannel@1942478618)
-- P recursing; t = RecT0
-- P entering recursion body; t = RecT0
```
Please note that some examples, including `a_PingPongAll.nuscr`, infinitely
recurse and can be terminated by `ctrl-c`.

The first time `runScala` is used, `sbt` may take additional time to fetch
dependencies and compile the **Effpi** library.

---
---

## 2. Benchmarking

Results used in the paper can be found in the following two files:

```
Lib/Teatrino/benchmark/metrics-2023-02-10.csv
Lib/Teatrino/benchmark/results-2023-02-10.csv
```

The `metrics` file comprises the contents of Table 1. The `results` file
contains generation times compiled by Criterion, and was used to produce
Fig. 13, and Fig. 15 in the full version.

To run the benchmarks yourself, execute the following command:

```bash
$ cd Lib/Teatrino \
    && stack bench \
    && cd /home/mpst
```

Metrics and timing results will be displayed for each example as benchmarking
proceeds. Benchmarking may take approximately 6 to 8 minutes to run. Results can
be found in the `Lib/Teatrino/benchmark` directory.

In `metrics.csv`, `numInteractions` reports the number of interaction statements
in the protocol, `numChans` reports the number of channels declared in the
generated entry point, `numFuns` reports the number of role-implementing
functions generated, `numCrashBranches` reports the number of `crash` labels in
the global type, and `maxDepth` reports the length of the longest continuation
in the protocol.

In `results.csv`, benchmark names are of the form `Stage/Example`, where
`Example` is the name of the variant (e.g. `a_PingPongAll`) and `Stage` is one
of `ReadFile`, `EffpiGen`, `ScalaGen`, and `Together`. The first three of these
stages corresponds to those given in Fig. 13 and Fig. 15 in the full version.
Where, `ReadFile` corresponds to Parsing, `EffpiGen` corresponds to EffpiIR
generation, and `ScalaGen` corresponds to Code Generation. Lastly, `Together`
corresponds to total generation time.

The results reported in the paper were taken running **Teatrino** directly on
the test machine reported in the paper, and not within this Docker container.
Accordingly, generation times taken within the docker container may be subject
to increased variance due to the small (less than 3 milliseconds) average
generation times.

---
---

## 3. Artefact Layout

We enumerate the contents of the home user directory (`/home/mpst/`) below.

- `Lib/Teatrino/`: contains the source code for our **Teatrino** tool. We use the
  Stack build system.
- `build.sbt`: is the Scala sbt build file used to compile and run the generated
  code.
- `effpi/`: contains the extended **Effpi** concurrency library. Note that
    references to authors and/or copyright holders are to **original** authors
    and/or copyright holders of the library.
- `examples/`: contains example protocols.
- `genAll.sh*`: generates code using **Teatrino** for all Scribble files in `effpi`.
- `project/`: configuration files used by `build.sbt`.
- `runScala.sh*`: script for running a single Scala file generated by **Teatrino**.

The home user directory may also contain the below subdirectories.

- `scala/`: default output directory for generated code, produced by **Teatrino**.
- `effpi_sandbox/`: used to run generated code, produced by `runScala.sh`.

---
---

## Appendix: Additional Information

---

### A.1 Toolchain Overview

The source for **Teatrino** comprises a Stack project that can be found in
`Lib/Teatrino`. This directory contains `package.yaml` and `Teatrino.cabal`
configuration files, with the latter generated automatically by Stack. The
project defines three targets: the base library, an executable, and our
benchmark suite. Both the executable and benchmark suite depend upon the
library.

#### **The Teatrino Library**

The library code can be found in the `src/` subdirectory, and contains the
following.

- `Core.hs` defines roles, labels, ground types, global types, and local types.
  Corresponds Fig. 7. Runtime types are not implemented. Global and local types
  are extended with annotations, used for generating Effpi channels, as
  described in Sec. 6.3 and Appendix C.
- `EffpiIR.hs` defines our intermediate representation for Effpi, EffpiIR.
  Defines specific annotation instances and merging behaviour.
- `Effpi.hs` contains functions for generating EffpiIR from a given global type.
- `IR.hs` defines an intermediate representation of global types, used in
  parsing.
- `Parser.hs` defines a simple Scribble parser using the ParSec parser
  combinator library.
- `Projection.hs` implements the projection operator in Def. 3. We omit those
  clauses defining projection and merging for runtime types. Projection supports
  annotations via the `Annot` type class defined in this module.
- `Scala.hs` implements pretty printing functions that generate concrete Scala
  code from EffpiIR.
- Utility Modules
    - `BaseUtils.hs`
    - `ParserUtils.hs`
    - `Utils.hs`
    - `ErrOr.hs`
    - `PPrinter.hs`

#### **The Teatrino Executable**

The entry point `app/Main.hs` module implements the command line interface.


#### **The Benchmarking Suite**

The entry point `benchmark/Main.hs` module contains code to gather and print
metrics and defines specific benchmarks using the Criterion library.

---

### A.2 Extended Scribble Syntax

**Teatrino** accepts a subset of the Scribble syntax accepted by
[nuScr](https://nuscr.dev/nuscr/), with two extensions to support our
crash-handling model. To illustrate this syntax, and demonstrate how you can
write communications protocols that will be accepted by **Teatrino**, we use the
protocol in `examples/Sec2_SimplerLogging.nuscr`.

```java
// Declares a global type, called SimplerLogging, with three roles.
// The `reliable` keyword asserts that roles L and I are assumed reliable.
global protocol SimplerLogging(reliable role L, role Cl, reliable role I) {
  // An interaction statement with one branch.
  // L is the sender and I is the receiver.
  // This requires no crash-handling branch since L is assumed reliable.
  trigger from L to I;
  // 'Directed' choice, denoting interaction with multiple branches.
  choice at Cl {
    read from Cl to I;
    read from I to L;
    report(Log) from L to I;
    report(Log) from I to Cl;
    // End of protocol (with no crashes).
  } or { // The crash-handling branch.
    crash from Cl to I; // `crash` is a reserved label.
    fatal from I to L;
    // End of protocol (where Cl has crashed).
  }
}
```

Recursion can be expressed using the `rec` and `continue` constructs, as seen in
`examples/a_PingPongAll.nuscr`.

```java
global protocol PingPongAll(reliable role P, reliable role Q) {
  rec t0 {
    ping from P to Q;
    pong from Q to P;
    continue t0;
  }
}
```

**Teatrino** does not currently accept `do`-recursion syntax or auxiliary
protocol definitions. In cases where a file contains multiple global protocol
definitions, only the first is parsed.

---

### A.3 Extended Effpi Syntax

Code generated by **Teatrino** uses an extended form of the **Effpi**
concurrency library. You may further specialise the generated code by replacing
default values and behaviours. We illustrate this using an extended form of the
code generated from `examples/Sec6_SimpleLogger.nuscr`.


```scala
package effpi_sandbox.Sec6_SimpleLogger

import effpi.process._
import effpi.process.dsl._
import effpi.channel.Channel
import effpi.channel.{InChannel, OutChannel}
import scala.concurrent.duration.Duration

// payload and label types
case class Log()
case class Read()
case class Report(x : Log)
case class Write(x : String)

// recursion variable t0
sealed abstract class RecT0[A]() extends RecVar[A]("RecT0")
case object RecT0 extends RecT0[Unit]

// local type declaration for role U
type U[C0 <: OutChannel[Read | Write], C1 <: InChannel[Report]] =
  Rec[RecT0, ((Out[C0, Read] >>: In[C1, Report, (x0 : Report) => Loop[RecT0]]) | (Out[C0, Write] >>: Loop[RecT0]))]

// Omitting local type declarations for role L.
...

implicit val timeout: Duration = Duration("60 seconds")

// role-implementing function for role U
// We extend u with a new parameter, `rw`, which determines whether U wishes
// to write to or read from the log.
def u(c0 : OutChannel[Read | Write], c1 : InChannel[Report], rw : Some<String>)
      : U[c0.type, c1.type] = {
  rec(RecT0) {
    println("-- U entering recursion body; t = RecT0")
    // we replace the default if-statement with a case expression on rw
    rw match {
    case None =>
      send(c0, new Read()) >> {
        println(s"-- U sent Read on c0 ($c0)")
        println(s"-- U expecting Report on c1 ($c1)")
        receive(c1) {(x1 : Report) =>
          println(s"-- U received Report on c1 ($c1)")
          println("-- U recursing; t = RecT0")
          loop(RecT0)
        }
      }
    case Some(str) =>
      // we replace the default empty string with `str`
      send(c0, new Write(str)) >> {
        println(s"-- U sent Write on c0 ($c0)")
        println("-- U recursing; t = RecT0")
        loop(RecT0)
      }
    }
  }
}

// ...role-implementing functions for role L

object Main {
  def main() : Unit = main(Array())

  def main(args : Array[String]) = {
    var rw = Some("42") // define rw; here, we will always write 42 to the log
    var c0 = Channel[Read | Write]()
    var c1 = Channel[Report]()

    eval(par(u(c0, c1, rw), l(c0, c1))) // pass rw to u
  }
}
```

Here, we trivially extend the protocol to write 42 to the log in perpetuity by
adding a new argument to one of our role-implementing functions and replacing
default values. The local types are unchanged, as is the role-implementing
function `l`, and this compiles and runs via `runScala.sh`. Further
modifications, excluding edits to the local type, are possible.

---

### A.4 Discrepancies between the Paper and Artefact

To improve our presentation, we have abbreviated some of the **Effpi** type
names in Fig. 3 and 12. Specifically, we use `InChan` and `OutChan` in lieu of
`InChannel` and `OutChannel` that are used in **Effpi**. `InChan` and `OutChan`
can be used validly in generated code by renaming `InChannel` and `OutChannel`:
```scala
import effpi.channel.{InChannel => IChan, OutChannel => OChan}
```

**Teatrino** does not currently accept roles called `C` due to our
implementation of fresh variable generation. In our example protocols, all roles
`C` have been renamed to `Cl`. An alternative approach to fresh variable
generation would avoid this limitation.

