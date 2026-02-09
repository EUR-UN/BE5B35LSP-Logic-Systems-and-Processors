> 🌍 **Language**: [🇨🇳 中文 (CN)](./README_CN.md) | [🇨🇿 Čeština (CZ)](./README_CZ.md)

# 🎓 LSP - Logic Systems and Processors

> **Course**: LSP (Logické systémy a procesory) — Logic Systems and Processors  
> **School**: CTU FEL Prague  
> **Last update**: 2026-01-15

---

## 📚 Overview

This repository contains complete study materials for the CTU FEL LSP course, including:
- 📝 Past exams and solutions (2015–2026)
- 📖 Notes and review guides
- 🔧 Lab tasks and FPGA projects
- 📊 Practice problems and example sets
- 🎯 **V3.0 Exam Cram Manual** (LaTeX, tri-language CN/EN/CZ)

---

## 📁 Repository layout

```
LSP/
├── EXAM/                           # 📝 Exam materials
│   ├── 00_Study_Resources_Common/  # 📖 Shared resources (CN/EN/CZ + Printable PDFs)
│   ├── 99_LaTeX_Source_Project/    # 🎯 LaTeX source project(s)
│   │   └── LSP_Revision_Master_2026/    # V3.0 LaTeX exam cram manual
│   ├── 2015-01-07/                 # Past exams (per-date folders)
│   ├── ...
│   ├── 2026-01-13/
│   ├── LSP_Ultimate_Review_Guide_EN.md  # Ultimate review guide (CN/EN/CZ + Printable PDF)
│   ├── Study_Index_Complete.md     # 📚 Master index (start here)
│   └── README.md                   # EXAM folder index
│
├── TASK/                           # 🔧 Lab tasks
│   ├── 1/                          # Task 1
│   ├── 2/task2/                    # Task 2 (Quartus)
│   ├── 3/                          # Task 3
│   ├── 4/                          # Task 4 (FSM)
│   └── STUDOCU/                    # Studocu materials
│
├── WEEK1-13/                       # 📖 Weekly notes
│   ├── WEEK1/  - Intro
│   ├── WEEK2/  - Logic functions
│   ├── WEEK3/  - VHDL concurrency
│   ├── WEEK4/  - VHDL advanced
│   ├── WEEK5/  - LCD + process
│   ├── WEEK6/  - CMOS + simulation
│   ├── WEEK7/  - Memory + DFF
│   ├── WEEK8/  - Fixed-point + metastability
│   ├── WEEK9/  - FSM
│   ├── WEEK10/ - Control unit FSA
│   ├── WEEK11/ - RISC-V
│   ├── WEEK12/ - Cache
│   └── WEEK13/ - Pipeline ALU
│
├── tools/                          # 🛠️ Tools
│   ├── md2pdf.py                   # Markdown → PDF
│   └── batch_convert.py            # 批量转换
│
├── BinaryPrerequisite_V20.pdf      # Binary prerequisites
├── LogicCircuitsOnFPGAs.pdf        # Logic circuits on FPGAs
└── README.md                       # This file
```

---

## 🎯 Core topics

### 1️⃣ Digital logic basics
- Boolean algebra and logic gates
- Karnaugh maps (K-Map)
- De Morgan's laws
- Shannon expansion

### 2️⃣ Combinational circuits
- Multiplexers / demultiplexers
- Encoders / decoders
- Adder design (full adder, +1 adder)

### 3️⃣ Sequential circuits
- RS latch (NOR/NAND)
- D / T flip-flops
- Registers and counters
- State machines (Moore/Mealy)

### 4️⃣ VHDL
- Concurrent vs sequential statements
- Signals vs variables
- Processes and sensitivity lists
- RTL view / synthesis sanity checks

### 5️⃣ Computer architecture
- 5-stage pipeline
- Data hazards and forwarding
- ~~Branch prediction~~ (not tested this time)
- ~~Cache~~ (not tested this time)

---

## 📝 Exam info (Jan 2026)

| Item | Details |
|------|------|
| Date | 2026-01-13 10:00 |
| Room | KN-A-310 |
| Duration | 90 minutes |
| Problems | 8–9 |
| Language | Czech / English |

### ⭐ 2026 must-know (teacher-confirmed)
1. Signed / unsigned arithmetic
2. K-Map equivalence for logic functions
3. RS latch waveform analysis
4. Shannon expansion
5. Processor pipeline

### ❌ Not tested this time
- ~~Branch prediction~~
- ~~Cache~~

See [EXAM/README.md](EXAM/README.md)

---

## 🔧 Lab environment

- **FPGA**: Intel Quartus Prime
- **Board**: VeekMT2 (Cyclone IV)
- **Simulation**: ModelSim / GHDL
- **Language**: VHDL

---

## 📖 Suggested study order

1. 📕 Start with the master index: [EXAM/Study_Index_Complete.md](EXAM/Study_Index_Complete.md)
2. 📘 Review guide (EN): [EXAM/LSP_Ultimate_Review_Guide_EN.md](EXAM/LSP_Ultimate_Review_Guide_EN.md)
3. 📗 Practice: [EXAM/00_Study_Resources_Common/Legacy_Selected_Examples_Collection.md](EXAM/00_Study_Resources_Common/Legacy_Selected_Examples_Collection.md)
4. 📙 Do the latest 3 years (2023–2025), prioritize exams with solutions

---

## 🔗 Links

- 📌 [CTU FEL](https://fel.cvut.cz)
- 📌 [Course page](https://cw.fel.cvut.cz/wiki/courses/b0b35lsp)

---

## ⚠️ Disclaimer

- For study/reference only
- Solutions may contain mistakes; official sources prevail
- Follow academic integrity rules

---

## 📊 Changelog

| Date | Change |
|------|--------|
| 2026-01-15 | Global README tri-lingualization (CN/EN/CZ) + smart links |
| 2026-01-13 | Updated index and recent exam materials (CN/EN/CZ + Printable PDFs) |
| 2025-06 | Added 2025 summer exams |

---

*Good luck with your exam!*
