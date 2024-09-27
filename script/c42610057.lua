--黄金拼图 大宫忍
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.guesstg)
	e2:SetOperation(cm.guessop)
	c:RegisterEffect(e2)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND) and g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_EARTH)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.tgtfilter(c)
    return c:IsLink(2) and c:IsAbleToGrave()
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgtfilter,tp,0x40,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,0x40)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.tgtfilter,tp,0x40,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function cm.tggfilter(c,tp)
    return not c:IsPublic() and c:IsAbleToRemove(c)
end

function cm.guesstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,0x0c,0)
	if chk==0 then return #g>1 and Duel.IsExistingMatchingCard(cm.tggfilter,tp,0x02,0,1,nil,tp) and g:IsExists(Card.IsAbleToGrave,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g-1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0x02)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function cm.guessop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(cm.tggfilter,tp,0x02,0,nil,tp)
    if #g==0 then return false end
    if Duel.GetFieldGroupCount(tp,0x02,0)>1 then Duel.ShuffleHand(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	g=g:Select(tp,1,1,nil)
    if #g>0 then
        local type=Duel.AnnounceType(1-tp)
        Duel.ConfirmCards(1-tp,g)
        local fg=Duel.GetFieldGroup(tp,0x0c,0)
        if g:GetFirst():IsType(0x1<<type) then
            if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) then
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        elseif #fg>1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            fg=fg:FilterSelect(tp,Card.IsAbleToGrave,#fg-1,#fg-1,nil)
            if #fg>0 then
                Duel.SendtoGrave(fg,REASON_RULE)
            end
        end
    end
end