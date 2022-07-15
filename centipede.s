################################################################################
#
# CSC258 Winter 2021 Assembly Centipede Game
# University of Toronto, St. George
#
# Student: Kirill Tregubov
#
# This project is a modified version of the popular 1980 Atari game Centipede
# built in MIPS assembly.
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Features:
# 1. Animations
#    a. Continually repaints the screen with appropriate assets
#    b. Draws 10-segment Centipede (with distinct head segment and zigzag
#       movement), Bug Blaster, Dart, Mushrooms and Fleas
#    c. Once the Centipede reaches the bottom it invades the Bug Blaster's space
# 2. Player Controls
#    a. Move the Bug Blaster along the bottom of the screen using the "j" key to
#       move left, "k" key to move right with keyboard input
#    b. Shoot out Darts using the "x" key with keyboard input
#    c. Start and Retry using the "s" key with keyboard input
#    d. Quit the game at any time using the "q" key with keyboard input
# 3. Core Gameplay Features
#    a. Mushrooms are randomly generated when the game starts
#    b. Fleas randomly spawn at the top and fall down, they have a chance of
#       spawning a Mushroom while falling
#    c. The Centipede dies after 3 Dart hits, Fleas die and Mushrooms are
#       destroyed after 1 Dart hit
#    d. Only one Dart can be travelling at a time
#    e. The Bug Blaster (player) loses a life when the Centipede or a Flea
#       intersect with it
#    f. Start, Game Over and Retry screens help provide a better experience
# 4. Extra Features
#    a. A scoreboard is displayed on the top left of the screen, it increments
#       by 10 when the Centipede dies, by 5 when a Flea dies, by 1 when a
#       Mushroom is destroyed
#    b. The player has 5 lives and the number of lives is displayed on the top
#       right of the screen, the game ends when all lives are exhausted
#    c. Important messages are displayed on the screen in text
#
# Additional Information:
#    - The direction constants are: 0 - North, 1 - East, 2 - South, 3 - West
################################################################################
.data
  displayAddress:	.word 0x10008000
  screenWidth: .word 64
  screenHeight: .word 64
  centipedeArray: .word 0:10
  centipedeLength: .word 10
  mushroomAmount: .word 20
  dartColor: .word 0x566bef
  fleaColor: .word 0xbb00ff
  mushroomColor: .word 0x8f5600
  centipedeBodyColor: .word 0x8cfc03
  centipedeHeadColor: .word 0x03fcba
  blasterBodyColor: .word 0xffaa00
  blasterEyeColor: .word 0x00ff00
  int_0: .word 4, 8, 256, 268, 512, 524, 768, 780, 1028, 1032, -1
  int_1: .word 8, 260, 264, 520, 776, 1032, -1
  int_2: .word 4, 8, 256, 268, 520, 772, 1024, 1028, 1032, 1036, -1
  int_3: .word 0, 4, 8, 268, 516, 520, 780, 1024, 1028, 1032, -1
  int_4: .word 0, 12, 256, 268, 512, 516, 520, 524, 780, 1036, -1
  int_5: .word 0, 4, 8, 12, 256, 512, 516, 520, 780, 1024, 1028, 1032, -1
  int_6: .word 4, 8, 256, 512, 516, 520, 768, 780, 1028, 1032, -1
  int_7: .word 0, 4, 8, 12, 268, 520, 776, 1032, -1
  int_8: .word 4, 8, 256, 268, 516, 520, 768, 780, 1028, 1032, -1
  int_9: .word 4, 8, 256, 268, 516, 520, 524, 780, 1028, 1032, -1
  lossText: .word 4, 8, 256, 512, 520, 524, 768, 780, 1028, 1032,
      24, 28, 276, 288, 532, 536, 540, 544, 788, 800, 1044, 1056,
      40, 52, 296, 300, 304, 308, 552, 564, 808, 820, 1064, 1076, 
      60, 64, 68, 72, 316, 572, 576, 580, 828, 1084, 1088, 1092, 1096,
      96, 100, 348, 360, 604, 616, 860, 872, 1120, 1124,
      112, 120, 368, 376, 624, 632, 880, 888, 1140,
      128, 132, 136, 140, 384, 640, 644, 648, 896, 1152, 1156, 1160, 1164
      148, 152, 156, 404, 416, 660, 664, 668, 916, 924, 1172, 1184,
      -1
  startText: .word 4, 8, 12, 256, 516, 520, 780, 1024, 1028, 1032,
      32, 36, 40, 292, 548, 804, 1060,
      52, 56, 304, 316, 560, 572, 816, 828, 1076, 1080,
      84, 88, 92, 336, 596, 600, 860, 1104, 1108, 1112,
      100, 104, 108, 360, 616, 872, 1128,
      120, 124, 372, 384, 628, 632, 636, 640, 884, 896, 1140, 1152,
      136, 140, 144, 392, 404, 648, 652, 656, 904, 912, 1160, 1172,
      156, 160, 164, 416, 672, 928, 1184,
      -1
  fleaOverwrite: .word 0
  fleaOverwriteColor: .word 0
  playerLives: .word 5
  delayTime: .word 75
  
################################################################################
# Initialize Game Data
.globl main
.text
main:
  # wipe board
  jal clear_board
  
  # Wait to start
  jal handle_start
  j skip_start
  
skip_start:
  jal clear_board
  
  # Instanciate + Load Variables
  lw $s0, playerLives
  move $s1, $zero
  move $s5, $zero
  move $s6, $zero
  
  # Draw Blaster
  jal generate_blaster
  
  # Generate and Draw
  jal generate_mushrooms
  jal handle_regen
  
  # Update Dashboard
  jal update_score
  jal update_lives
  
  jal long_delay

################################################################################
# Game Loop
Loop:
  # check player death
  bne $s0, $zero, loop_skip_loss
  j Exit
loop_skip_loss:
  
  jal check_keystroke
  jal handle_centipede
  jal handle_flea
  move $a0, $zero
  jal handle_darts
  move $a0, $zero
  jal handle_darts
  
  # check centipede death
  bne $s3, $zero, loop_skip_regen
  jal delete_centipede
  addi $s5, $s5, 10
  jal update_score
  jal handle_regen
loop_skip_regen:
  
  jal delay
  j Loop

################################################################################
# Exit
Exit:
  # delete blaster
  move $a0, $zero
  move $a1, $a0
  lw $a2, displayAddress
  add $a2, $a2, $s2
  jal paint_blaster
  
  jal print_game_over
  
  jal handle_start
  j skip_start

################################################################################
# Handle Start
handle_start:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t1, screenHeight
  sra $t1, $t1, 1
  addi $t1, $t1, -3
handle_start_outer_loop:
  lw $t2, screenHeight
  sra $t2, $t2, 1
  addi $t2, $t2, 2
  beq $t1, $t2, handle_start_end
  li $t0, 10
handle_start_loop:
  li $t2, 52
  beq $t0, $t2, handle_start_check
  move $a0, $t0
  move $a1, $t1
  jal calculate_position
  move $a0, $v0
  move $a1, $zero
  jal paint_entity
  addi $t0, $t0, 1
  j handle_start_loop
handle_start_check:
  addi $t1, $t1, 1
  j handle_start_outer_loop
handle_start_end:
  
  li $a0, 10
  lw $a1, screenHeight
  sra $a1, $a1, 1
  addi $a1, $a1, -3
  jal calculate_position
  move $t0, $v0
  
  la $t4, startText
handle_start_paint_loop:
  lw $t5, 0($t4)
  li $t1, -1
  beq $t5, $t1, handle_start_paint
  add $a0, $t0, $t5
  li $a1, 0xffffff
  jal paint_entity
  addi $t4, $t4, 4
  j handle_start_paint_loop
handle_start_paint:
  
  move $v0, $zero
wait_start:
  bne $v0, $zero, handle_start_skip
  jal check_start
  j wait_start
handle_start_skip:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Print Game Over
print_game_over:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $t1, 2
exit_outer_loop:
  li $t2, 7
  beq $t1, $t2, exit_end
  li $t0, 22
exit_loop:
  li $t2, 63
  beq $t0, $t2, exit_check
  move $a0, $t0
  move $a1, $t1
  jal calculate_position
  move $a0, $v0
  move $a1, $zero
  jal paint_entity
  addi $t0, $t0, 1
  j exit_loop
exit_check:
  addi $t1, $t1, 1
  j exit_outer_loop
exit_end:
  
  li $a0, 22
  li $a1, 2
  jal calculate_position
  move $t0, $v0
  
  la $t4, lossText
exit_paint_loop:
  lw $t5, 0($t4)
  li $t1, -1
  beq $t5, $t1, exit_paint
  add $a0, $t0, $t5
  li $a1, 0xffffff
  jal paint_entity
  addi $t4, $t4, 4
  j exit_paint_loop
exit_paint:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
  

################################################################################
# Handle Centipede
handle_centipede:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  jal find_centipede_move
  move $t0, $v0
  move $t1, $v1
  
  move $a0, $t0
  jal get_entity
  lw $t2, dartColor
  bne $v0, $t2, handle_centipede_skip # handle dart collision
  addi $s3, $s3, -1
  move $s1, $zero
handle_centipede_skip:
  
  la $t3, centipedeArray
  lw $t4, centipedeLength
  addi $t4, $t4, -1
  move $t5, $zero
  
handle_centipede_loop:
  sll $t6, $t5, 2
  add $t6, $t3, $t6
  beq $t5, $t4, handle_centipede_end
  lw $t7, 4($t6)
  
  bne $t5, $zero, handle_centipede_tail
  lw $t8, 0($t6)
handle_centipede_tail:

  sw $t7, 0($t6)
  addi $t5, $t5, 1
  j handle_centipede_loop
handle_centipede_end:

  sw $t0, 0($t6)
  move $s4, $t1
  
  # delete tail
  move $a0, $t8
  move $a1, $zero
  jal paint_entity
  
  jal paint_centipede

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Handle Flea
handle_flea:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  bne $s6, $zero, handle_flea_skip_init
  li $a1, 30
  li $v0, 42
  syscall
  bne $a0, $zero, handle_flea_skip_init
handle_flea_retry:
  li $a1, 65
  li $v0, 42
  syscall
  li $a1, 8
  jal calculate_position
  move $a0, $v0
  jal get_entity
  bne $v0, $zero, handle_flea_retry
  lw $a1, fleaColor
  jal paint_entity
  move $s6, $a0
  j handle_flea_end
handle_flea_skip_init:
  
  beq $s6, $zero, handle_flea_end
  move $t0, $zero
handle_flea_movement:
  li $t1, 2
  beq $t0, $t1, handle_flea_end
  
  # delete old flea
  move $a0, $s6
  jal get_entity
  lw $a1, fleaColor
  bne $v0, $a1, handle_flea_delete_old
  move $a1, $zero
  jal paint_entity
handle_flea_delete_old:

  # dart out of bounds
  li $t3, 256
  div $s6, $t3
  mflo $t3
  li $t4, 63
  bne $t3, $t4, handle_flea_bounds_skip
  move $s6, $zero
  j handle_flea_end
handle_flea_bounds_skip:
  
  la $t1, fleaOverwrite
  la $t2, fleaOverwriteColor
  lw $a0, 0($t1)
  
  # generate mushroom
  bne $a0, $zero, handle_flea_skip_generate
  li $t3, 256
  div $s6, $t3
  mflo $t3
  li $t4, 58
  bgt $t3, $t4, handle_flea_skip_generate
  li $a1, 10
  li $v0, 42
  syscall
  bne $a0, $zero, handle_flea_skip_generate
  move $a0, $s6
  lw $a1, mushroomColor
  jal paint_entity
handle_flea_skip_generate:
  
  # paint old block
  lw $a0, 0($t1)
  beq $a0, $zero, handle_flea_skip_old
  lw $a1, 0($t2)
  jal paint_entity
  sw $zero, 0($t1)
  sw $zero, 0($t2)
handle_flea_skip_old:
  
  addi $t3, $s6, 256
  move $a0, $t3
  jal get_entity
  beq $v0, $zero, handle_flea_paint
  
  # check centipede collision
  lw $t4, centipedeHeadColor
  lw $t5, centipedeBodyColor
  move $t6, $zero
  bne $v0, $t4, handle_flea_skip_check
  li $t6, 1
handle_flea_skip_check:
  bne $v0, $t5, handle_flea_skip_check_2
  li $t6, 1
handle_flea_skip_check_2:
  beq $t6, $zero, handle_flea_skip_centipede
  move $s6, $t3
  j handle_flea_end
handle_flea_skip_centipede:
  
  # check mushroom collision
  move $a0, $t3
  jal get_entity
  lw $t4, mushroomColor
  bne $v0, $t4, handle_flea_skip_mushroom
  sw $a0, 0($t1)
  sw $v0, 0($t2)
  j handle_flea_paint
handle_flea_skip_mushroom:
  
  # check dart collision
  move $a0, $t3
  jal get_entity
  lw $t4, dartColor
  bne $v0, $t4, handle_flea_skip_dart
  move $a1, $zero
  jal paint_entity
  addi $s5, $s5, 5
  jal update_score
  move $s1, $zero
  move $s6, $zero
  j handle_flea_end
handle_flea_skip_dart:

  # check player collision
  move $a0, $t3
  jal is_blaster
  beq $v0, $zero, handle_flea_skip_player
  move $s6, $zero
  move $a0, $zero
  j damage_player
handle_flea_skip_player:
  
handle_flea_paint:
  move $a0, $t3
  lw $a1, fleaColor
  jal paint_entity
  move $s6, $a0
  
handle_flea_loop_end:
  addi $t0, $t0, 1
  j handle_flea_movement
  
handle_flea_end:
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Handle Darts
handle_darts:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  bne $a0, $zero, handle_darts_skip_delete
  
  beq $s1, $zero, handle_darts_end
  li $t0, 256
  div $s1, $t0
  mflo $t1
  li $t2, 6
  bne $t1, $t2, handle_darts_skip # dart out of bounds
  move $a0, $s1
  move $a1, $zero
  jal paint_entity
  move $s1, $zero
  j handle_darts_end
handle_darts_skip:
  
  # delete old dart
  move $a0, $s1
  jal get_entity
  lw $t0, dartColor
  move $t1, $zero
  move $a1, $t1
  jal paint_entity

handle_darts_skip_delete:
  
  # check mushroom collision
  addi $a0, $s1, -256
  jal get_entity
  lw $t2, mushroomColor
  bne $v0, $t2, handle_darts_skip_mushroom
  move $a1, $t1
  jal paint_entity
  addi $s5, $s5, 1
  jal update_score
  move $s1, $zero
  j handle_darts_end
handle_darts_skip_mushroom:
  
  # check centipede collision
  jal get_entity
  lw $t2, centipedeHeadColor
  lw $t3, centipedeBodyColor
  move $t4, $zero
  bne $v0, $t2, handle_darts_skip_check
  li $t4, 1
handle_darts_skip_check:
  bne $v0, $t3, handle_darts_skip_check_2
  li $t4, 1
handle_darts_skip_check_2:
  beq $t4, $zero, handle_darts_skip_centipede
  addi $s3, $s3, -1
  move $s1, $zero
  j handle_darts_end
handle_darts_skip_centipede:

  # check flea collision
  jal get_entity
  lw $t2, fleaColor
  bne $v0, $t2, handle_darts_skip_flea
  move $a1, $t1
  jal paint_entity
  addi $s5, $s5, 5
  jal update_score
  move $s1, $zero
  move $s6, $zero
  j handle_darts_end
handle_darts_skip_flea:
  
  lw $a1, dartColor
  jal paint_entity
  move $s1, $a0
handle_darts_end:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Handle Regen
handle_regen:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $s3, 3
  jal generate_centipede
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Handle Regen
clear_board:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $a0, $zero
  li $t0, 16384
  move $a1, $zero
clear_board_loop:
  beq $a0, $t0, clear_board_end
  jal paint_entity
  addi $a0, $a0, 4
  j clear_board_loop
clear_board_end:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Generate Blaster
generate_blaster:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t0, screenWidth
  lw $t1, screenHeight
  sra $a0, $t0, 1		# $a0 stores x coordinate
  addi $a1, $t1, -2	# $a1 stores y coordinate
  jal calculate_position
  add $s2, $zero, $v0	# $s2 stores blaster location
  move $a0, $zero # specify painting init
  jal move_blaster
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Generate Mushrooms
# Overwrites:
#   $t1, $t6, $t7, $t8, $t9
generate_mushrooms:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t8, mushroomAmount
  move $t1, $zero
generate_mushroom_loop:
  beq $t1, $t8, generate_mushroom_end
  jal get_random_position

  # paint mushroom
  move $a0, $v0
  lw $a1, mushroomColor
  jal paint_entity

  addi $t1, $t1, 1
  j generate_mushroom_loop
generate_mushroom_end:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Generate Centipede
generate_centipede:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  la $t0, centipedeArray
  lw $t2, centipedeLength
  move $t3, $zero
generate_centipede_loop:
  beq $t3, $t2, generate_centipede_end
  sll $t4, $t3, 2
  add $t5, $t0, $t4
  addi $t4, $t4, 1792
  sw $t4, 0($t5)
  
  addi $t6, $t2, -1
  bne $t3, $t6, skip_head_assignment
  li $s4, 1
skip_head_assignment:

  addi $t3, $t3, 1
  j generate_centipede_loop
generate_centipede_end:

  jal paint_centipede

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Paint Centipede
# Overwrites:
#   $t0, $t1, $t2, $t3
paint_centipede:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  la $t0, centipedeArray
  lw $t1, centipedeLength
  addi $t1, $t1, -1
  move $t2, $zero
paint_centipede_loop:
  sll $t3, $t2, 2
  add $t3, $t0, $t3
  beq $t2, $t1, paint_centipede_end
  lw $a0, 0($t3)
  lw $a1, centipedeBodyColor
  jal paint_entity
  
  addi $t2, $t2, 1
  j paint_centipede_loop
paint_centipede_end:
  lw $a0, 0($t3)
  lw $a1, centipedeHeadColor
  jal paint_entity

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Delete Centipede
# Overwrites:
#   $t0, $t1, $t2, $t3
delete_centipede:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  la $t0, centipedeArray
  lw $t1, centipedeLength
  move $t2, $zero
delete_centipede_loop:
  beq $t2, $t1, delete_centipede_end
  sll $t3, $t2, 2
  add $t3, $t0, $t3
  lw $a0, 0($t3)
  move $a1, $zero
  jal paint_entity
  
  addi $t2, $t2, 1
  j delete_centipede_loop
delete_centipede_end:

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
  
################################################################################
# Damage Player
# Input:
#   $a0: is_centipede
damage_player:
  # delete blaster
  move $a3, $a0
  move $a0, $zero
  move $a1, $a0
  lw $a2, displayAddress
  add $a2, $a2, $s2
  jal paint_blaster
  
  # update lives
  addi $s0, $s0, -1
  jal update_lives
  jal long_delay
  
  # generate blaster
  jal generate_blaster
  
  beq $s0, $zero, damage_player_skip
  beq $a3, $zero, damage_player_skip # centipede collision
  jal delete_centipede
  jal handle_regen
damage_player_skip:
  j Loop

################################################################################
# Update Lives
update_lives:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $t1, 3
update_lives_clear_outer_loop:
  li $t2, 5
  beq $t1, $t2, update_lives_clear_end
  li $t0, 44
update_lives_clear_loop:
  li $t2, 63
  beq $t0, $t2, update_lives_clear_check
  move $a0, $t0
  move $a1, $t1
  jal calculate_position
  move $a0, $v0
  move $a1, $zero
  jal paint_entity
  addi $t0, $t0, 1
  j update_lives_clear_loop
update_lives_clear_check:
  addi $t1, $t1, 1
  j update_lives_clear_outer_loop
update_lives_clear_end:
  
  move $t0, $zero
  lw $t1, screenWidth
  addi $t2, $t1, -2
update_lives_loop:
  beq $t0, $s0, update_lives_end
  
  # get center of heart
  move $a0, $t2
  li $a1, 3
  jal calculate_position
  move $t3, $v0
  
  move $t4, $zero
  move $t5, $t3
  li $a1, 0xff0000
update_lives_paint_loop:
  li $t1, 3
  beq $t4, $t1, update_lives_paint_exit
  la $a0, 0($t5)
  jal paint_entity
  addi $t5, $t5, -4
  addi $t4, $t4, 1
  j update_lives_paint_loop
update_lives_paint_exit:
  la $a0, 264($t5)
  jal paint_entity
  addi $t2, $t2, -4
  addi $t0, $t0, 1
  j update_lives_loop
update_lives_end:

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Update Score
update_score:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $t1, 2
update_score_clear_outer_loop:
  li $t2, 7
  beq $t1, $t2, update_score_clear_end
  li $t0, 1
update_score_clear_loop:
  li $t2, 15
  beq $t0, $t2, update_score_clear_check
  move $a0, $t0
  move $a1, $t1
  jal calculate_position
  move $a0, $v0
  move $a1, $zero
  jal paint_entity
  addi $t0, $t0, 1
  j update_score_clear_loop
update_score_clear_check:
  addi $t1, $t1, 1
  j update_score_clear_outer_loop
update_score_clear_end:
  
  move $t0, $zero
  move $t6, $s5
update_score_loop:
  li $t1, 3
  beq $t0, $t1, update_score_end
  sub $t2, $t1, $t0
  mul $t2, $t2, 5
  addi $t2, $t2, -4

  move $a0, $t2
  li $a1, 2
  jal calculate_position
  move $t3, $v0
  
  li $t1, 10
  div $t6, $t1
  mfhi $t7
  mflo $t6
  la $t4, int_0
  li $t1, 1
  bne $t7, $t1, update_score_one
  la $t4, int_1
update_score_one:
  li $t1, 2
  bne $t7, $t1, update_score_two
  la $t4, int_2
update_score_two:
  li $t1, 3
  bne $t7, $t1, update_score_three
  la $t4, int_3
update_score_three:
  li $t1, 4
  bne $t7, $t1, update_score_four
  la $t4, int_4
update_score_four:
  li $t1, 5
  bne $t7, $t1, update_score_five
  la $t4, int_5
update_score_five:
  li $t1, 6
  bne $t7, $t1, update_score_six
  la $t4, int_6
update_score_six:
  li $t1, 7
  bne $t7, $t1, update_score_seven
  la $t4, int_7
update_score_seven:
  li $t1, 8
  bne $t7, $t1, update_score_eight
  la $t4, int_8
update_score_eight:
  li $t1, 9
  bne $t7, $t1, update_score_paint_loop
  la $t4, int_9
  
update_score_paint_loop:
  lw $t5, 0($t4)
  li $t1, -1
  beq $t5, $t1, update_score_paint_exit
  add $a0, $t3, $t5
  li $a1, 0xffffff
  jal paint_entity
  addi $t4, $t4, 4
  j update_score_paint_loop
update_score_paint_exit:
  addi $t0, $t0, 1
  j update_score_loop
update_score_end:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Check all keystrokes
check_keystroke:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t8, 0xffff0000
  bne $t8, 1, skip_keyboard_input
  jal get_keyboard_input # if key is pressed, jump to get this key

skip_keyboard_input:
  move $t8, $zero
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Check Start
check_start:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t8, 0xffff0000
  beq $t8, 1, get_start_input # if key is pressed, jump to get this key
  move $t8, $zero
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Get keyboard input keys
get_keyboard_input:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t2, 0xffff0004
  move $v0, $zero	# default case
  bne $t2, 0x6A, skip_j_response
  jal respond_to_j
  j return_keyboard

skip_j_response:
  bne $t2, 0x6B, skip_k_response
  jal respond_to_k
  j return_keyboard

skip_k_response:
  bne $t2, 0x78, skip_x_response
  jal respond_to_x
  j return_keyboard

skip_x_response:
  bne $t2, 0x71, return_keyboard
  jal respond_to_q

return_keyboard:
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Get start input keys
get_start_input:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  lw $t2, 0xffff0004
  move $v0, $zero	# default case
  beq $t2, 0x73, respond_to_s
  beq $t2, 0x71, respond_to_q
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Call back function of j key
respond_to_j:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $a0, $s2
  jal check_edge
  move $t0, $v0
  li $t1, 1

  beq $t0, $t1, respond_to_j_skip # prevent the bug from getting out of the canvas
  li $a0, 1
  jal move_blaster
  addi $s2, $s2, -4

respond_to_j_skip:
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Call back function of k key
respond_to_k:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $a0, $s2
  jal check_edge
  move $t0, $v0
  li $t1, 2

  beq $t0, $t1, respond_to_k_skip # prevent the bug from getting out of the canvas
  li $a0, 2
  jal move_blaster
  addi $s2, $s2, 4

respond_to_k_skip:
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Call back function of x key
respond_to_x:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  bne $s1, $zero, respond_to_x_skip
  add $s1, $s2, -512
  li $a0, 1
  jal handle_darts

respond_to_x_skip:
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Call back function of s key
respond_to_s:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $v0, 1
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Call back function of q key
respond_to_q:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $a0, $zero
  move $a1, $a0
  lw $a2, displayAddress
  add $a2, $a2, $s2
  jal paint_blaster
  
  jal print_game_over
  
  li $v0, 10	# terminate the program gracefully
  syscall
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Delay
delay:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $v0, 32
  lw $a0, delayTime
  syscall
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Delay
long_delay:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $v0, 32
  lw $a0, delayTime
  mul $a0, $a0, 5
  syscall
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Calculate pixel position
# Input:
#   $a0: x coordinate
#   $a1: y coordinate
# Overwrites:
#   $t8
calculate_position:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $v0, $zero
  beq $a1, $zero, skip_shift
  addi $a1, $a1, -1
  mul $v0, $a1, 256
skip_shift:
  sll $t8, $a0, 2
  add $v0, $v0, $t8
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Get Random Position
get_random_position:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  li $a1, 3317
  li $v0, 42
  syscall
  addi $a0, $a0, 459
  sll $v0, $a0, 2
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Check if given position is edge
# Input:
#   $a0: position on screen
# Overwrites:
#   $t8, $t9
check_edge:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $v0, $zero
  li $t8, 256
  div $a0, $t8
  mfhi $t9
  
  li $t8, 4
  bne $t9, $t8, check_if
  li $v0, 1
check_if:
  li $t8, 248
  bne $t9, $t8, check_else
  li $v0, 2
check_else:
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Find the next centipede move
# Overwrites:
#   $t6, $t7, $t8, $t9
find_centipede_move:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  # check side collision
  la $t5, centipedeArray	
  lw $t6, 36($t5) 	# $t6: head position
  move $t7, $zero		# $t7: edge value
  li $t8, 256
  div $t6, $t8
  mfhi $t9
  bne $t9, $zero, find_cmove_check_if
  li $t7, 1
find_cmove_check_if:
  li $t8, 252
  bne $t9, $t8, find_cmove_check_else
  li $t7, 2
find_cmove_check_else:

  # handle overflow
  li $t5, 1
  bne $t7, $t5, find_cmove_edge_if # if at left edge
  li $t5, 3
  bne $s4, $t5, find_cmove_edge_if # if direction west
  addi $v0, $t6, 256	# move down
  li $v1, 1
  j find_cmove_end
find_cmove_edge_if:
  li $t5, 2
  bne $t7, $t5, find_cmove_edge_skip # if at right edge
  li $t5, 1
  bne $s4, $t5, find_cmove_edge_skip # if direction east
  addi $v0, $t6, 256	# move down
  li $v1, 3
  j find_cmove_end
find_cmove_edge_skip:

  # determine next unit
  li $t5, 1
  bne $s4, $t5, find_cmove_next_east # if direction east
  addi $v0, $t6, 4	# move east
find_cmove_next_east:
  li $t5, 3
  bne $s4, $t5, find_cmove_next_west # if direction west
  addi $v0, $t6, -4	# move west
find_cmove_next_west:
  move $v1, $s4
  
  # check blaster
  move $a0, $v0
  jal is_blaster
  move $t9, $v0
  move $v0, $a0
  beq $t9, $zero, find_cmove_skip_blaster
  li $a0, 1
  j damage_player
find_cmove_skip_blaster:
  
  # handle mushrooms
  li $t8, 2
  div $s4, $t8
  mfhi $t9		# $t9: direction heading
  lw $t8, displayAddress	# $t0 stores the base address for display
  add $t8, $t8, $v0	# $t3 is the address of the old bug location
  lw $t5, 0($t8)
  lw $t8, mushroomColor
  bne $t5, $t8, find_cmove_end # if destination is mushroom
  beq $t9, $zero, find_cmove_end # if direction east/west
  addi $v0, $t6, 256	# move south
  li $t5, 1
  bne $s4, $t5, find_cmove_skip_east # if direction east
  li $v1, 3
find_cmove_skip_east:
  li $t5, 3
  bne $s4, $t5, find_cmove_end # if direction west
  li $v1, 1
find_cmove_end:

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
  
################################################################################
# Move blaster - move blaster in given direction
# Input:
#   $a0: travel direction
# Overwrites:
#   $t0, $t1, $t3
move_blaster:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  lw $t0, displayAddress  # $t0 stores the base address for display
  move $t1, $a0
  add $t3, $t0, $s2	# $t3 stores old location
  beq $a0, 0, skip_deletion

  # delete blaster
  move $a0, $zero
  move $a1, $a0
  move $a2, $t3
  jal paint_blaster
skip_deletion:

  bne $t1, 2, blaster_if
  addi $t3, $t3, 4
blaster_if:
  bne $t1, 1, blaster_else
  addi $t3, $t3, -4
blaster_else:

  lw $a0, blasterBodyColor
  lw $a1, blasterEyeColor
  move $a2, $t3
  jal paint_blaster

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Paint Blaster - paint blaster in given colors at given coordinate
# Inputs:
#   $a0: body color code
#   $a1: eye color code
#   $a2: coordinate
paint_blaster:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  sw $a1, -260($a2)
  sw $a1, -252($a2)
  sw $a0, -512($a2)
  sw $a0, -256($a2)
  sw $a0, -4($a2)
  sw $a0, 0($a2)
  sw $a0, 4($a2)
  sw $a0, 256($a2)
  
  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Is Blaster - returns 1 if given coordinate is blaster
# Input:
#   $a0: coordinate
# Overwrites:
#   $t8, $t9
is_blaster:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  move $v0, $zero
  lw $t8, displayAddress
  add $t8, $t8, $a0
  lw $t9, 0($t8)
  lw $t8, blasterBodyColor
  bne $t9, $t8, is_blaster_skip # if destination is blaster body
  li $v0, 1
is_blaster_skip:
  lw $t8, blasterEyeColor
  bne $t9, $t8, is_blaster_skip_2 # if destination is blaster eye
  li $v0, 1
is_blaster_skip_2:

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Paint Entity - paint given coordinate in given color
# Input:
#   $a0: coordinate
#   $a1: color code
# Overwrites:
#   $t9
paint_entity:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  lw $t9, displayAddress
  add $t9, $t9, $a0
  sw $a1, 0($t9)

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

################################################################################
# Get Entity - get color at given coordinate
# Input:
#   $a0: coordinate
# Overwrites:
#   $t9
get_entity:
  # save caller
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  lw $t9, displayAddress
  add $t9, $t9, $a0
  lw $v0, 0($t9)

  # return to caller
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
