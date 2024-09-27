--幻星集 命运之占卜
local m=66660030
local cm=_G["c"..m]
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(cm.condition)
	e3:SetCountLimit(1)
	e3:SetOperation(cm.chop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCondition(cm.condition1)
	e4:SetOperation(cm.chop1)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit)
	c:RegisterEffect(e2)
end
function cm.chop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
    Duel.ChangeTargetCard(ev,g)
	return Duel.ChangeChainOperation(ev,cm.repop)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_MONSTER)
end
function cm.penfilter(c)
		return c:IsSetCard(0x666) and c:IsType(TYPE_PENDULUM)
end
function cm.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=2 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local ct=g:GetCount()
	if ct>0 and g:FilterCount(cm.penfilter,nil,e,tp)>0
		 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:FilterSelect(tp,cm.penfilter,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	end
Duel.ShuffleDeck(tp)
end

function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetTurnPlayer()==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function cm.chop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
    Duel.ChangeTargetCard(ev,g)
	return Duel.ChangeChainOperation(ev,cm.repop1)
end
function cm.repop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=2 then return end
	Duel.ConfirmDecktop(1-tp,3)
	local g=Duel.GetDecktopGroup(1-tp,3)
	local ct=g:GetCount()
	if ct>0 and g:FilterCount(cm.penfilter,nil,e,1-tp)>0
		 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:FilterSelect(tp,cm.penfilter,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	end
Duel.ShuffleDeck(1-tp)
end
function cm.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x666)
end