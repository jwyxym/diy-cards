--CH.000 《未来姬战纪-爱尔比斯》
function c10100000.initial_effect(c)
	--
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon rule
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetCode(EFFECT_SPSUMMON_PROC)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetCondition(c10100000.sprcon)
	e01:SetTarget(c10100000.sprtg)
	e01:SetOperation(c10100000.sprop)
	c:RegisterEffect(e01)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10100000.atkval)
	c:RegisterEffect(e1)
	local e11=e1:Clone()
	e11:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e11)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e22=e2:Clone()
	e22:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e22)
	--atk limit
	local e23=Effect.CreateEffect(c)
	e23:SetType(EFFECT_TYPE_FIELD)
	e23:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e23:SetRange(LOCATION_MZONE)
	e23:SetTargetRange(0,LOCATION_MZONE)
	e23:SetValue(c10100000.atklimit)
	c:RegisterEffect(e23)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10100000.discon)
	e3:SetTarget(c10100000.distg)
	e3:SetOperation(c10100000.disop)
	c:RegisterEffect(e3)
end
function c10100000.sprfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGraveAsCost()
end
function c10100000.fselect(g,tp,sc)
	if not aux.gffcheck(g,Card.IsType,TYPE_TUNER,aux.NOT(Card.IsType),TYPE_TUNER)
		or Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0 then return false end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1:IsLevel(tc2:GetLevel())
end
function c10100000.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c10100000.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c10100000.fselect,2,2,tp,c)
end
function c10100000.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(c10100000.sprfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,c10100000.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c10100000.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
function c10100000.atkfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SYNCHRO) and c:GetLevel()>0
end
function c10100000.atkval(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(c10100000.atkfilter,tp,LOCATION_MZONE,LOCATION_GRAVE,nil)
	return g:GetSum(Card.GetLevel)*300
end
function c10100000.atklimit(e,c)
	return c~=e:GetHandler()
end
function c10100000.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function c10100000.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsControlerCanBeChanged,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c10100000.disop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateEffect(ev) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.GetControl(g:GetFirst(),tp,PHASE_END,1)
	end
end