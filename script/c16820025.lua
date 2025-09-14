--梭巡游侠 推论
function c16820025.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c16820025.ffilter,2,true)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--special summon
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetCode(EFFECT_SPSUMMON_PROC)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetCondition(c16820025.spcon)
	e01:SetTarget(c16820025.sptg)
	e01:SetOperation(c16820025.spop)
	c:RegisterEffect(e01)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,16820025)
	e1:SetTarget(c16820025.thtg)
	e1:SetOperation(c16820025.thop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c16820025.atkcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xdf28))
	e2:SetValue(c16820025.atkval)
	c:RegisterEffect(e2)
	c16820025.discard_effect=e1
end
function c16820025.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xdf28) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
function c16820025.fusfilter(c)
	return c:IsSetCard(0xdf28) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function c16820025.fselect(g)
	return g:GetClassCount(Card.GetCode)==2 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
end
function c16820025.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local fg=Duel.GetMatchingGroup(c16820025.fusfilter,tp,0x30,0,nil)
	return fg:CheckSubGroup(c16820025.fselect,2,2)
end
function c16820025.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	local g=Duel.GetMatchingGroup(c16820025.fusfilter,cp,0x30,0,nil)
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(cp,c16820025.fselect,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c16820025.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	Duel.SendtoDeck(sg,nil,0,REASON_COST)
	Duel.ConfirmDecktop(tp,#sg)
	Duel.ShuffleDeck(tp)
end
function c16820025.thfilter(c)
	return c:IsSetCard(0xdf28) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceupEx() and c:IsAbleToHand()
end
function c16820025.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820025.thfilter,tp,0x30,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0x30)
end
function c16820025.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16820025.thfilter),tp,0x30,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(16820025,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
				local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
			end
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c16820025.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c16820025.splimit(e,c)
	return not c:IsLevel(1) and not c:IsRank(1) and not c:IsLink(1)
end
function c16820025.atkcon(e)
	return Duel.IsBattlePhase()
end
function c16820025.atkval(e,c)
	return e:GetHandler():GetBaseAttack()
end