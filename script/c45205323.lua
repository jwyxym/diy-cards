---侦探：案件调查 (45205323)
local s,id,o=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<3 then return false end
        return true
    end
    Duel.SetOperationInfo(0,CATEGORY_DECK_CONFIRM,nil,3,1-tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=1-tp
    
    if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<3 then return end
    
    local g=Duel.GetDecktopGroup(p,3)
    if #g<3 then return end
    
    Duel.ConfirmCards(tp,g)
    Duel.ConfirmCards(p,g)
    
    local has_monster=false
    local has_spell=false
    local has_trap=false
    local tc=g:GetFirst()
    while tc do
        if tc:IsType(TYPE_MONSTER) then has_monster=true end
        if tc:IsType(TYPE_SPELL) then has_spell=true end
        if tc:IsType(TYPE_TRAP) then has_trap=true end
        tc=g:GetNext()
    end
    
    local all_three = has_monster and has_spell and has_trap
    if all_three then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
    
    local options={}
    
    if has_spell and Duel.IsExistingMatchingCard(s.magfilter,tp,LOCATION_DECK,0,1,nil,id) then
        options[#options+1]=1
    end
    
    if has_trap and Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_GRAVE,0,1,nil) then
        options[#options+1]=2
    end
    
    if has_monster and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_DECK,0,1,nil) then
        options[#options+1]=3
    end
    
    if #options==0 then return end
    
    local choice=1
    if #options>1 then
        local param_list={tp}
        for i=1,#options do
            param_list[#param_list+1]=aux.Stringid(id,options[i])
        end
        choice=Duel.SelectOption(table.unpack(param_list))+1
    end
    
    local selected=options[choice]
    
    if selected==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.magfilter,tp,LOCATION_DECK,0,1,1,nil,id)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    elseif selected==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    elseif selected==3 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
    
    Duel.ShuffleDeck(p)
end

function s.magfilter(c,selfcode)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:GetCode()~=selfcode
end

function s.gravefilter(c)
    return c:IsSetCard(0x1D5C) and c:IsAbleToHand()
end

function s.monsterfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER)
end