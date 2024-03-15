//
//  HealthComponent.swift
//  TowerForge
//
//  Created by MacBook Pro on 15/03/24.
//

import Foundation

class HealthComponent: TFComponent {
    public var currentHealth: Int
    public var maxHealth: Int
    
    init(maxHealth: Int) {
        self.currentHealth = maxHealth
        self.maxHealth = maxHealth
        super.init()
    }
    
    func decreaseHealth(amount: Int) {
        self.currentHealth -= amount
    }
    
    func increaseHealth(amount: Int) {
        self.currentHealth = min(self.currentHealth + amount, self.maxHealth)
    }
    
    func restoreHealth() {
        self.currentHealth = maxHealth
    }
}
