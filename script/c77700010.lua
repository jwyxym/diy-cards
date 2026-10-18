local s,id=GetID()

function s.filter(c)
    return true
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end

    local is_own_szone = tc:IsControler(tp) and tc:IsLocation(LOCATION_SZONE)
    local is_szone_monster = is_own_szone and tc:IsFaceup() and (tc:GetOriginalType() & TYPE_MONSTER) ~= 0
    local is_not_abyss = not tc:IsCode(id)

    -- 只有破坏“自己魔陷区的、非天书深渊的卡”时，才设置标记
    if is_own_szone and is_not_abyss then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
    end

    local g=Group.CreateGroup()
    g:AddCard(c)
    if tc~=c then g:AddCard(tc) end

    if Duel.Destroy(g, REASON_EFFECT) == 0 then return end

    if is_szone_monster
        and tc:IsLocation(LOCATION_GRAVE)
        and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        Duel.Damage(1-tp,800,REASON_EFFECT)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id) > 0
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
    -- 触发后立即清除标记，防止本回合后续误触发
    Duel.ResetFlagEffect(tp, id)
end