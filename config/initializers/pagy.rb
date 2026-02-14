# frozen_string_literal: true

require "pagy/extras/overflow"

# Pagy initializer for proper frontend rendering
Pagy::DEFAULT[:overflow] = :last_page
