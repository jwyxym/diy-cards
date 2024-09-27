--NEWGAME! 饭岛结音
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
    e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_TO_DECK)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,m)
    e4:SetCondition(cm.thcon)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
	--todeck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,m+1)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
end

function cm.lcheck(g,lc)
	return g:GetClassCount(Card.GetCode)==#g
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

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_LINK)
end

function cm.tgrlfilter(g)
	local loc=0
	for tc in aux.Next(g) do
		loc=loc|tc:GetPreviousLocation()
	end
	return loc
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rl=cm.tgrlfilter(eg)
    if chk==0 then return rl~=0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,rl,0,1,nil) end
	e:SetLabel(rl)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,rl)
end

function cm.optfilter(c)
	return c:IsFaceup() and c:GetAttack()~=0
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,e:GetLabel(),0,1,5,nil)
	if #g>0 then
		if g:FilterCount(Card.IsLocation,nil,0x3c)>0 then
			Duel.HintSelection(g:Filter(Card.IsLocation,nil,0x3c))
		end
		Duel.SendtoDeck(g,tp,2,REASON_EFFECT)
	end
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0x0e,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,4,tp,0x1e)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToChain() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0x0e,0,1,3,nil)
		if #g>0 then
			if g:FilterCount(Card.IsLocation,nil,0x0c)>0 then
				Duel.HintSelection(g:Filter(Card.IsLocation,nil,0x0c))
			end
			g:AddCard(c)
			Duel.SendtoDeck(g,tp,2,REASON_EFFECT)
		end
	end
end