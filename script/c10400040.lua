--大千录 苍蜣登阶
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.acon)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(this.dcost)
    e2:SetTarget(this.dtg)
    e2:SetOperation(this.dop)
    c:RegisterEffect(e2)
end
function this.afilter(c,e,tp)
    return c:IsCode(10400010) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp)<=1000
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        and Duel.GetLocationCountFromEx(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,this.afilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CHANGE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        if Duel.GetTurnPlayer()==tp then
            e1:SetReset(RESET_PHASE+PHASE_END,2)
        else
            e1:SetReset(RESET_PHASE+PHASE_END,1)
        end
        e1:SetValue(0)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        Duel.RegisterEffect(e2,tp)
	end
end
function this.dfilter(c)
    return c:IsSetCard(0x3981) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function this.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,this.dfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function this.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_GRAVE)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function this.dop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,LOCATION_DECKSHF,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Draw(p,d,REASON_EFFECT)
    end
end
