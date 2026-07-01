--山铜魔龙
--卡密ID: 45205522

local s,id=GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 48179391) 
    --①效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)
    
    --②效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHANGE_POS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.poscon)
    e2:SetTarget(s.optiontg)
    e2:SetOperation(s.optionop)
    c:RegisterEffect(e2)
    
    --③效果
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    e3:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e3)
end

--①效果
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local pos=tc:GetPosition()
        if (pos&POS_FACEUP_ATTACK)~=0 then
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
        elseif (pos&POS_FACEUP_DEFENSE)~=0 then
            Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
        end
    end
end

--②效果条件
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return tc and tc:GetControler()==tp
end

--②检索过滤
function s.searchfilter(c)
    if not c or not c.IsCode then return false end
    return c:IsAbleToHand() and (c:IsCode(48179391) or aux.IsCodeOrListed(c,48179391))
end

function s.optiontg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1 = Duel.GetFlagEffect(tp,id+200)==0 and Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        local b2 = Duel.GetFlagEffect(tp,id+300)==0 and Duel.IsPlayerCanDraw(tp,1)
        return b1 or b2
    end
end

function s.optionop(e,tp,eg,ep,ev,re,r,rp)
    local canSearch = Duel.GetFlagEffect(tp,id+200)==0 and Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    local canDraw = Duel.GetFlagEffect(tp,id+300)==0 and Duel.IsPlayerCanDraw(tp,1)
    
    if not canSearch and not canDraw then return end
    
    local opts = {}
    if canSearch then table.insert(opts, aux.Stringid(id,2)) end
    if canDraw then table.insert(opts, aux.Stringid(id,3)) end
    
    local choice = Duel.SelectOption(tp, table.unpack(opts)) + 1
    
    if choice == 1 and canSearch then
        Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    elseif (choice == 2 and canDraw) or (choice == 1 and not canSearch and canDraw) then
        Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

--③效果
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA)
end