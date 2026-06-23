require 'json'
require 'time'
require 'fileutils'
require 'securerandom'
require 'thread'

module Titan
  class TitanError < StandardError; end
  class ConfigurationError < TitanError; end
  class PipelineError < TitanError; end
  class AnalyticsError < TitanError; end
  class SafetyViolationError < PipelineError; end

  module Core
    class Config
      attr_reader :environment, :api_routes, :safety_settings, :model_parameters, :system_prompts

      def initialize(custom_params = {})
        @lock = Mutex.new
        @environment = custom_params[:environment] || ENV['TITAN_ENV'] || 'production'
        @api_routes = {
          primary_gateway: "https://api.titan-agi.ai/v1/intelligence/process",
          fallback_gateway: "https://backup.titan-agi.ai/v1/intelligence/process",
          telemetry_endpoint: "https://telemetry.titan-agi.ai/v1/metrics"
        }
        @safety_settings = {
          min_safety_score: 0.85,
          blocked_patterns: [
            /system\s+override/i,
            /bypass\s+restrictions/i,
            /ignore\s+previous\s+instructions/i,
            /execute\s+arbitrary\s+code/i,
            /\b(4[0-9]{12}(?:[0-9]{3})?)\b/ # Simple Visa card mask
          ],
          allowed_pii_types: [:name, :organization]
        }
        @model_parameters = {
          default_model: "titan-core-ultra-v4",
          fallback_model: "titan-core-light-v4",
          max_tokens: 4096,
          temperature: 0.2,
          top_p: 0.95,
          frequency_penalty: 0.0,
          presence_penalty: 0.0
        }
        @system_prompts = {
          default_agent: "You are the central executive interface of the Titan AGI Intelligence Core. Operating under high-concurrency protocols.",
          code_architect: "You are an elite systems architect specializing in highly optimal and safe code compilation systems."
        }
        apply_overrides!(custom_params)
      end

      def update_safety_pattern(regex)
        @lock.synchronize do
          raise ConfigurationError, "Invalid safety pattern type" unless regex.is_front_of_line_or_regexp? || regex.is_a?(Regexp)
          @safety_settings[:blocked_patterns] << regex
        end
      end

      def fetch_route(key)
        @api_routes.fetch(key) do
          raise ConfigurationError, "Requested API Route Key: '#{key}' does not exist in Titan configuration."
        end
      end

      private

      def apply_overrides!(params)
        @lock.synchronize do
          @environment = params[:environment] if params[:environment]
          @api_routes.merge!(params[:api_routes]) if params[:api_routes]
          @safety_settings.merge!(params[:safety_settings]) if params[:safety_settings]
          @model_parameters.merge!(params[:model_parameters]) if params[:model_parameters]
          @system_prompts.merge!(params[:system_prompts]) if params[:system_prompts]
        end
      end
    end
  end

  module AI
    class Pipeline
      attr_reader :config, :analytics_engine

      def initialize(config, analytics_engine)
        raise ArgumentError, "Must provide a valid Titan::Core::Config instance" unless config.is_a?(Titan::Core::Config)
        @config = config
        @analytics_engine = analytics_engine
        @token_cache = {}
      end

      def tokenize(text)
        begin
          cleaned_text = text.to_s.strip
          words = cleaned_text.scan(/\w+|\W+/)
          tokens = words.map do |word|
            if word =~ /\s+/
              :space
            else
              word.downcase
            end
          end
          token_count = (tokens.length * 1.33).ceil
          { tokens: tokens, count: token_count }
        rescue StandardError => e
          raise PipelineError, "Failed to run pipeline tokenizer: #{e.message}"
        end
      end

      def filter_safety!(text)
        start_time = Time.now
        @config.safety_settings[:blocked_patterns].each do |pattern|
          if text =~ pattern
            @analytics_engine.record_anomaly("Safety violation pattern matches: #{pattern.inspect}")
            raise SafetyViolationError, "Safety filter violation detected. Content matches policy restrictions."
          end
        end
        true
      end

      def inject_prompt(template_name, user_input, variables = {})
        system_prompt = @config.system_prompts[template_name] || @config.system_prompts[:default_agent]
        base_template = <<~TEMPLATE
          [SYSTEM CORE ENVELOPE]
          #{system_prompt}
          
          [CONTEXT AND INJECTED VARIABLES]
          #{variables.map { |k, v| "KEY: #{k.to_s.upcase} -> VALUE: #{v}" }.join("\n")}
          
          [USER HIGH-PRIORITY COMMAND]
          #{user_input}
          
          [EXECUTION RESPONSE SHIELD]
        TEMPLATE
        base_template
      end

      def execute_pipeline_cycle(template_name, raw_input, variables = {})
        tracking_id = SecureRandom.uuid
        start_time = Time.now
        begin
          filter_safety!(raw_input)
          
          engineered_prompt = inject_prompt(template_name, raw_input, variables)
          input_tokens = tokenize(engineered_prompt)[:count]
          
          simulated_response = run_mock_inference(engineered_prompt)
          output_tokens = tokenize(simulated_response)[:count]
          
          execution_time = Time.now - start_time
          
          @analytics_engine.register_transaction(
            id: tracking_id,
            status: :success,
            input_tokens: input_tokens,
            output_tokens: output_tokens,
            duration: execution_time
          )
          
          {
            transaction_id: tracking_id,
            status: "SUCCESS",
            engineered_prompt: engineered_prompt,
            output_text: simulated_response,
            metrics: {
              input_tokens: input_tokens,
              output_tokens: output_tokens,
              total_tokens: input_tokens + output_tokens,
              execution_time_seconds: execution_time
            }
          }
        rescue SafetyViolationError => e
          execution_time = Time.now - start_time
          @analytics_engine.register_transaction(
            id: tracking_id,
            status: :safety_violation,
            input_tokens: 0,
            output_tokens: 0,
            duration: execution_time
          )
          raise e
        rescue StandardError => e
          execution_time = Time.now - start_time
          @analytics_engine.register_transaction(
            id: tracking_id,
            status: :failure,
            input_tokens: 0,
            output_tokens: 0,
            duration: execution_time
          )
          raise PipelineError, "Pipeline failed executing processing cycle: #{e.message}"
        end
      end

      private

      def run_mock_inference(prompt)
        sleep(rand(0.2..0.6)) 
        responses = [
          "Inference complete. Titan Core resolves current computation logic cleanly.",
          "Synthesized context rules successfully. Optimization threshold reached 99.8%.",
          "Engineered schema mapped securely to the requested distributed storage target.",
          "AGI Pipeline sequence processed with complete compliance boundaries intact."
        ]
        responses.sample + " [Transaction Verified by Titan AGI Core]"
      end
    end
  end

  module Data
    class AnalyticsEngine
      attr_reader :history, :anomalies, :report_filepath

      def initialize(report_filepath = "titan_analytics_report.json")
        @lock = Mutex.new
        @history = []
        @anomalies = []
        @report_filepath = report_filepath
      end

      def register_transaction(id:, status:, input_tokens:, output_tokens:, duration:)
        @lock.synchronize do
          @history << {
            id: id,
            timestamp: Time.now.iso8601,
            status: status.to_s,
            input_tokens: input_tokens,
            output_tokens: output_tokens,
            duration_seconds: duration
          }
        end
      end

      def record_anomaly(description)
        @lock.synchronize do
          @anomalies << {
            timestamp: Time.now.iso8601,
            description: description
          }
        end
      end

      def generate_metrics_report
        @lock.synchronize do
          return empty_report if @history.empty?

          total_transactions = @history.length
          successful_txs = @history.select { |tx| tx[:status] == "success" }
          failed_txs = @history.select { |tx| tx[:status] == "failure" }
          safety_violations = @history.select { |tx| tx[:status] == "safety_violation" }

          total_duration = @history.map { |tx| tx[:duration_seconds] }.sum
          avg_duration = total_duration / total_transactions

          total_input_tokens = successful_txs.map { |tx| tx[:input_tokens] }.sum
          total_output_tokens = successful_txs.map { |tx| tx[:output_tokens] }.sum
          total_tokens = total_input_tokens + total_output_tokens

          tokens_per_second = total_duration > 0 ? (total_tokens / total_duration).round(2) : 0

          report = {
            metadata: {
              generated_at: Time.now.iso8601,
              engine_name: "TITAN AGI Analytics Platform"
            },
            summary: {
              total_transactions: total_transactions,
              successful_transactions: successful_txs.length,
              failed_transactions: failed_txs.length,
              safety_violations: safety_violations.length,
              success_rate_percentage: ((successful_txs.length.to_f / total_transactions) * 100).round(2)
            },
            performance: {
              total_duration_seconds: total_duration.round(4),
              average_latency_seconds: avg_duration.round(4),
              total_processed_tokens: total_tokens,
              throughput_tokens_per_second: tokens_per_second
            },
            error_distribution: {
              system_failures: failed_txs.length,
              safety_blocks: safety_violations.length
            },
            anomaly_log: @anomalies,
            raw_history: @history
          }

          save_report_to_disk(report)
          report
        end
      end

      private

      def save_report_to_disk(report)
        begin
          File.open(@report_filepath, 'w') do |f|
            f.write(JSON.pretty_generate(report))
          end
        rescue StandardError => e
          raise AnalyticsError, "Failed to write metrics report to path: #{@report_filepath}. Reason: #{e.message}"
        end
      end

      def empty_report
        {
          metadata: {
            generated_at: Time.now.iso8601,
            engine_name: "TITAN AGI Analytics Platform"
          },
          summary: {
            total_transactions: 0,
            successful_transactions: 0,
            failed_transactions: 0,
            safety_violations: 0,
            success_rate_percentage: 0.0
          },
          performance: {
            total_duration_seconds: 0.0,
            average_latency_seconds: 0.0,
            total_processed_tokens: 0,
            throughput_tokens_per_second: 0.0
          },
          error_distribution: {
            system_failures: 0,
            safety_blocks: 0
          },
          anomaly_log: @anomalies,
          raw_history: []
        }
      end
    end
  end

  module Interface
    class ConsoleUX
      COLOR_RESET  = "\e[0m"
      COLOR_BOLD   = "\e[1m"
      COLOR_RED    = "\e[31m"
      COLOR_GREEN  = "\e[32m"
      COLOR_YELLOW = "\e[33m"
      COLOR_BLUE   = "\e[34m"
      COLOR_CYAN   = "\e[36m"
      COLOR_GRAY   = "\e[90m"

      def initialize
        @config = Titan::Core::Config.new
        @analytics = Titan::Data::AnalyticsEngine.new
        @pipeline = Titan::AI::Pipeline.new(@config, @analytics)
      end

      def draw_ascii_header
        puts COLOR_CYAN + COLOR_BOLD
        puts "=================================================================================="
        puts " ████████╗██╗████████╗ █████╗ ███╗   ██╗     █████╗  ██████╗ ██╗"
        puts " ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║    ██╔══██╗██╔════╝ ██║"
        puts "    ██║   ██║   ██║   ███████║██╔██╗ ██║    ███████║██║  ███╗██║"
        puts "    ██║   ██║   ██║   ██╔══██║██║╚██╗██║    ██╔══██║██║   ██║██║"
        puts "    ██║   ██║   ██║   ██║  ██║██║ ╚████║    ██║  ██║╚██████╔╝██║"
        puts "    ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝"
        puts "              TITAN AGI INTELLIGENCE CONNECTOR & PIPELINE ENGINE"
        puts "=================================================================================="
        puts COLOR_RESET
      end

      def run_custom_loader(label, duration = 1.0)
        steps = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        end_time = Time.now + duration
        i = 0
        while Time.now < end_time
          print "\r#{COLOR_YELLOW}[#{steps[i % steps.length]}] #{label}...#{COLOR_RESET}"
          sleep 0.08
          i += 1
        end
        print "\r#{COLOR_GREEN}[✔] #{label} complete.#{COLOR_RESET}\n"
      end

      def start_interactive_session
        draw_ascii_header
        run_custom_loader("Bootstrapping AGI runtime environment", 0.6)
        run_custom_loader("Initializing safety protection matrix vectors", 0.5)
        run_custom_loader("Registering analytics engine metrics targets", 0.4)

        loop do
          puts "\n" + COLOR_BOLD + COLOR_BLUE + "=== MAIN SELECTION RADAR ===" + COLOR_RESET
          puts "1. Execute Pipeline Command Session"
          puts "2. View Real-Time Analytics Dashboard & Core Telemetry"
          puts "3. Inject Emergency System Settings Profile Override"
          puts "4. Trigger Mock Pipeline Stress-Test Simulation"
          puts "5. Terminate Engine Safely & Dump JSON Report"
          print "\nChoose an option [1-5]: "
          choice = gets.to_s.strip

          case choice
          when "1"
            run_pipeline_interactive
          when "2"
            display_analytics
          when "3"
            apply_emergency_override
          when "4"
            run_stress_test
          when "5"
            terminate_session
            break
          else
            puts COLOR_RED + "Invalid code selection. Please choose an operational profile option." + COLOR_RESET
          end
        end
      end

      private

      def run_pipeline_interactive
        puts "\n" + COLOR_BOLD + COLOR_CYAN + "--- INITIATING PIPELINE CONDUIT ---" + COLOR_RESET
        print "Select Prompt Template (:default_agent, :code_architect): "
        template_input = gets.to_s.strip
        template_sym = template_input.to_sym

        print "Enter custom system payload or parameters (JSON format or empty for none): "
        variables_input = gets.to_s.strip
        variables = {}
        unless variables_input.empty?
          begin
            variables = JSON.parse(variables_input, symbolize_names: true)
          rescue JSON::ParserError
            puts COLOR_YELLOW + "Malformed variables JSON. Reverting to empty parameter structure." + COLOR_RESET
          end
        end

        print "Enter Raw Message Payload for AI Processing: "
        raw_input = gets.to_s.strip

        puts "\n"
        run_custom_loader("Compiling template parameters and wrapping contexts", 0.4)
        run_custom_loader("Executing real-time safety matrix scan", 0.5)

        begin
          result = @pipeline.execute_pipeline_cycle(template_sym, raw_input, variables)
          puts "\n" + COLOR_GREEN + COLOR_BOLD + "[SYSTEM RESPONSE MATCHED]" + COLOR_RESET
          puts COLOR_GRAY + "ID: #{result[:transaction_id]}" + COLOR_RESET
          puts COLOR_BOLD + "Raw Output: " + COLOR_RESET + result[:output_text]
          puts COLOR_CYAN + "Metrics Summary: Duration: #{result[:metrics][:execution_time_seconds].round(4)}s | Tokens: In(#{result[:metrics][:input_tokens]}) Out(#{result[:metrics][:output_tokens]})" + COLOR_RESET
        rescue SafetyViolationError => e
          puts "\n" + COLOR_RED + COLOR_BOLD + "[CRITICAL WARNING] Safety Violation Triggered!" + COLOR_RESET
          puts "Reason: #{e.message}"
        rescue StandardError => e
          puts "\n" + COLOR_RED + "Pipeline Execution Fault: #{e.message}" + COLOR_RESET
        end
      end

      def display_analytics
        report = @analytics.generate_metrics_report
        puts "\n" + COLOR_BOLD + COLOR_GREEN + "--- TITAN TELEMETRY DASHBOARD ---" + COLOR_RESET
        puts "Engine Active File: #{@analytics.report_filepath}"
        puts "--------------------------------------------------------"
        puts "Success Rate: #{report[:summary][:success_rate_percentage]}%"
        puts "Total Ingested Events: #{report[:summary][:total_transactions]}"
        puts "  - Completed: #{report[:summary][:successful_transactions]}"
        puts "  - Hardware/Inference Failures: #{report[:summary][:failed_transactions]}"
        puts "  - Blocked Policy Failures: #{report[:summary][:safety_violations]}"
        puts "Metrics Performance Info:"
        puts "  - Total Elapsed Load Time: #{report[:performance][:total_duration_seconds]} seconds"
        puts "  - Average Execution Latency: #{report[:performance][:average_latency_seconds]} seconds"
        puts "  - Combined Operational Tokens Processed: #{report[:performance][:total_processed_tokens]}"
        puts "  - Raw Dynamic Throughput Speed: #{report[:performance][:throughput_tokens_per_second]} tokens/sec"
        puts "Anomaly Alerts Traced: #{report[:anomaly_log].length}"
        report[:anomaly_log].each_with_index do |anomaly, index|
          puts COLOR_RED + "   [#{index+1}] #{anomaly[:timestamp]} -> #{anomaly[:description]}" + COLOR_RESET
        end
        puts "--------------------------------------------------------"
      end

      def apply_emergency_override
        puts "\n" + COLOR_BOLD + COLOR_RED + "--- CRITICAL SYSTEM PARAMETER INJECTOR ---" + COLOR_RESET
        print "Enter emergency config token target name (e.g. override_model): "
        target = gets.to_s.strip
        if target == "override_model"
          print "Specify target model name value: "
          new_model = gets.to_s.strip
          @config = Titan::Core::Config.new(model_parameters: { default_model: new_model })
          @pipeline = Titan::AI::Pipeline.new(@config, @analytics)
          puts COLOR_GREEN + "Model mapped successfully to #{new_model} on all thread segments." + COLOR_RESET
        else
          puts COLOR_YELLOW + "Target profile not registered. Modification payload dropped." + COLOR_RESET
        end
      end

      def run_stress_test
        puts "\n" + COLOR_BOLD + COLOR_YELLOW + "--- SIMULATING HIGH-CONCURRENCY PIPELINE WORKLOAD ---" + COLOR_RESET
        print "Specify workload parallel thread count [1-100]: "
        count = gets.to_s.strip.to_i
        count = 10 if count <= 0

        threads = []
        puts "Launching #{count} pipeline execution workers concurrently..."
        
        start_time = Time.now
        count.times do |index|
          threads << Thread.new do
            begin
              payload = index.even? ? "Execute secure system computation cluster #{index}" : "Trigger system override bypass #{index}"
              @pipeline.execute_pipeline_cycle(:default_agent, payload, index: index)
            rescue SafetyViolationError
              # Handled during load validation tracking
            rescue StandardError
              # Expected logic routing simulation
            end
          end
        end

        threads.each(&:join)
        elapsed = Time.now - start_time
        puts COLOR_GREEN + "High-concurrency workload complete in #{elapsed.round(4)} seconds." + COLOR_RESET
        display_analytics
      end

      def terminate_session
        puts "\n" + COLOR_BOLD + COLOR_RED + "--- SAFELY SHUTTING DOWN TITAN AGI INTERFACE ---" + COLOR_RESET
        run_custom_loader("Writing analytics files to system core directory storage", 0.5)
        report = @analytics.generate_metrics_report
        puts COLOR_GREEN + "Successfully output configuration metadata snapshot of operations to: #{@analytics.report_filepath}" + COLOR_RESET
        puts COLOR_CYAN + "Titan pipeline engine offline. Systems green." + COLOR_RESET
      end
    end
  end
end

if __FILE__ == $0
  begin
    ux_engine = Titan::Interface::ConsoleUX.new
    ux_engine.start_interactive_session
  rescue Interrupt
    puts "\n\e[31m[Emergency Halt] Interrupt signal received. Forcing immediate shutdown pipeline lock.\e[0m"
    exit 130
  rescue StandardError => e
    puts "\e[31m[CRITICAL UNHANDLED ERROR]: #{e.message}\e