--ゴーストリック・デパーチャー
local s,id,o=GetID()
function s.initial_effect(c)
    -- 特殊发动条件：手卡发动（需要展示3张不同的鬼计场地魔法卡）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    e0:SetCost(s.handcost)
    c:RegisterEffect(e0)
    
    -- ①效果：变怪兽+检索
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    -- ②效果：墓地除外效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- 手卡发动条件
function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(s.cost_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    local name_map={}
    for tc in aux.Next(g) do
        name_map[tc:GetCode()]=true
    end
    local count=0
    for _ in pairs(name_map) do count=count+1 end
    return count>=3 and e:GetHandler():IsLocation(LOCATION_HAND)
end

-- 手卡发动的cost：展示3张不同的鬼计场地魔法卡
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.cost_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
        local name_map={}
        for tc in aux.Next(g) do
            name_map[tc:GetCode()]=true
        end
        local count=0
        for _ in pairs(name_map) do count=count+1 end
        return count>=3
    end
    
    local total_group=Duel.GetMatchingGroup(s.cost_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    local selected=Group.CreateGroup()
    while selected:GetCount()<3 do
        local available=total_group:Filter(function(c)
            return not selected:IsExists(Card.IsCode,1,nil,c:GetCode())
        end,nil)
        if available:GetCount()==0 then return false end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=available:Select(tp,1,1,nil)
        selected:Merge(g)
    end
    local hg=selected:Filter(Card.IsLocation,nil,LOCATION_HAND)
    local dg=selected:Filter(Card.IsLocation,nil,LOCATION_DECK)
	local og=selected-hg-dg
	Duel.ConfirmCards(tp,dg,true)
	Duel.ConfirmCards(1-tp,hg,true)
	Duel.ConfirmCards(1-tp,dg,true)
	Duel.HintSelection(og)	
	if hg:GetCount()>=1 then
		Duel.ShuffleHand(tp)
	end
	if dg:GetCount()>=1 then
		Duel.ShuffleDeck(tp)
    end
end

function s.cost_filter(c)
    return c:IsSetCard(0x8d) and c:IsType(TYPE_FIELD)
end

function s.thfilter(c)
    return c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:IsCostChecked()
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x8d,TYPES_NORMAL_TRAP_MONSTER,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x8d,TYPES_NORMAL_TRAP_MONSTER,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP,tp) then
        c:AddMonsterAttribute(TYPE_NORMAL)
        Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
        
        -- 检索效果
        if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
                Duel.Damage(tp,500,REASON_EFFECT)
            end
        end
        
        -- 自肃
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.fieldfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x8d) and c:IsType(TYPE_FIELD) or c:IsSetCard(0x8d) and c:IsType(TYPE_LINK))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
end

function s.filter(c,e,tp)
    -- 不能选无法变更形式的怪兽
    if not c:IsCanChangePosition() then return false end
    
    if c:IsFaceup() then
        -- 表侧表示：需要能抽卡
        return Duel.IsPlayerCanDraw(tp,1)
    else
        -- 里侧表示：需要能放置卡
        return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if tc:IsFaceup() then
            Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
            Duel.Draw(tp,1,REASON_EFFECT)
        else
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
            local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
            if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
                local sg=g:Select(tp,1,1,nil)
                if #sg>0 then
                    local tc=sg:GetFirst()
                    Duel.ShuffleDeck(tp)
                    Duel.HintSelection(sg)
                    if tc:IsLocation(LOCATION_DECK) then
                        Duel.MoveSequence(tc,SEQ_DECKTOP)
                    else
                        Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
                    end
                    if tc:IsLocation(LOCATION_DECK) then
                        Duel.ConfirmDecktop(tp,1)
                    end
                end
            end
        end
    end
end

function s.setfilter(c)
    return c:IsSetCard(0x8d)
end