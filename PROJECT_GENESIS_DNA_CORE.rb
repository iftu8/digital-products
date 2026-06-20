# frozen_string_literal: true

# ===================================================================================================
# 🧬 PROJECT NAME : GENESIS - SYNTHETIC BIOLOGICAL DATA STORAGE & MUTATION ENGINE
# ⚠️ CLEARANCE    : BLACK-OPS (EXTREMELY CLASSIFIED)
# 👑 ARCHITECT    : Iftu8 (Pioneer of Bio-Digital Engineering)
# 💰 MARKET VALUE : PRICELESS (NEXT-GEN 2050 TECHNOLOGY)
# 🛠️ STACK        : RUBY (Bitwise Operations, Polymorphic Enumerators, ANSI Visuals)
# ===================================================================================================
# DESCRIPTION:
# This engine transcends standard computing. It converts raw digital data into synthetic 
# DNA sequences (Adenine, Cytosine, Guanine, Thymine), applies cellular automations to 
# simulate organic mutation, and encrypts information at a biological level.
# ===================================================================================================

module BioDigitalCore
  # -------------------------------------------------------------------------
  # 🧬 MODULE 1: THE NUCLEOTIDE ENCODER
  # -------------------------------------------------------------------------
  class DNAEncoder
    # Mapping 2-bit binary pairs to DNA Nucleotides
    DNA_MAP = {
      '00' => 'A', # Adenine
      '01' => 'C', # Cytosine
      '10' => 'G', # Guanine
      '11' => 'T'  # Thymine
    }.freeze

    REVERSE_MAP = DNA_MAP.invert.freeze

    def self.encode_to_dna(string_data)
      # Convert string to binary, then pad to even length, then map to DNA
      binary_string = string_data.unpack1('B*')
      binary_string = "0#{binary_string}" if binary_string.length.odd?
      
      dna_sequence = binary_string.scan(/../).map { |pair| DNA_MAP[pair] }.join
      dna_sequence
    end
  end

  # -------------------------------------------------------------------------
  # 🦠 MODULE 2: POLYMORPHIC MUTATION ENGINE
  # -------------------------------------------------------------------------
  class MutationSimulator
    def self.apply_radiation(dna_sequence, mutation_rate: 0.05)
      nucleotides = %w[A C G T]
      mutated_sequence = dna_sequence.chars.map do |base|
        if rand < mutation_rate
          (nucleotides - [base]).sample # Organic mutation occurs
        else
          base
        end
      end.join
      
      mutated_sequence
    end
  end

  # -------------------------------------------------------------------------
  # 🖥️ MODULE 3: THE HOLOGRAPHIC TERMINAL RENDERER
  # -------------------------------------------------------------------------
  class HolographicDisplay
    HELIX_PHASES = [
      "\e[31m  A===T  \e[0m",
      "\e[35m C=====G \e[0m",
      "\e[34mT=======A\e[0m",
      "\e[36m G=====C \e[0m",
      "\e[32m  A===T  \e[0m",
      "\e[33m    |    \e[0m",
    ].freeze

    def self.render_boot_sequence
      system('clear') || system('cls')
      puts "\e[1m\e[32m"
      puts "  ██████╗ ███████╗███╗   ██╗███████╗███████╗██╗███████╗"
      puts " ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔════╝██║██╔════╝"
      puts " ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ███████╗██║███████╗"
      puts " ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║██║╚════██║"
      puts " ╚██████╔╝███████╗██║ ╚████║███████╗███████║██║███████║"
      puts "  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝╚══════╝\e[0m\n\n"
      puts "\e[36m[*] INITIATING BIO-DIGITAL CORE V2.0...\e[0m"
      sleep(1)
    end

    def self.render_helix(frames = 15)
      puts "\n\e[33m[🧬] SYNTHESIZING DNA STRAND...\e[0m\n"
      frames.times do |i|
        puts "        #{HELIX_PHASES[i % HELIX_PHASES.length]}"
        sleep(0.15)
      end
    end
  end
end

# ===================================================================================================
# 🚀 EXECUTION: INJECTING DATA INTO SYNTHETIC DNA
# ===================================================================================================

if __FILE__ == $PROGRAM_NAME
  BioDigitalCore::HolographicDisplay.render_boot_sequence

  # The highly classified data we want to store biologically
  secret_mission_data = "Iftu8_System_Override_Code_Omega"
  puts "\e[34m[!] RAW DATA       :\e[0m #{secret_mission_data}"

  # Encoding
  dna_code = BioDigitalCore::DNAEncoder.encode_to_dna(secret_mission_data)
  puts "\e[32m[+] DNA ENCODED    :\e[0m #{dna_code[0..40]}... (TRUNCATED)"
  
  # Visualizing the Helix
  BioDigitalCore::HolographicDisplay.render_helix

  # Applying simulated radiation/mutation
  puts "\n\e[31m[!] WARNING: APPLYING GAMMA RADIATION TO DNA SEQUENCE...\e[0m"
  sleep(1)
  mutated_dna = BioDigitalCore::MutationSimulator.apply_radiation(dna_code, mutation_rate: 0.15)
  
  # Calculating Damage
  damage_count = dna_code.chars.zip(mutated_dna.chars).count { |a, b| a != b }
  puts "\e[35m[*] MUTATION COMPLETED. \e[31m#{damage_count} NUCLEOTIDES ALTERED.\e[0m"
  puts "\e[32m[+] MUTATED STRAND :\e[0m #{mutated_dna[0..40]}... (TRUNCATED)"
  
  puts "\n\e[36m>> BIO-COMPUTATION CYCLE FINISHED. ENTERING DEEP SLEEP. <<\e[0m\n"
end
