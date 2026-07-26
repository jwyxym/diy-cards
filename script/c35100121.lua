--异质绝望领主 无妄战士
local m=35100121
local cm=_G["c"..m]
function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,3,cm.lcheck)
	c:EnableReviveLimit()
	--splimit
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_FIELD)
	e22:SetRange(LOCATION_MZONE)
	e22:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e22:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e22:SetTargetRange(0,1)
	e22:SetCondition(cm.negcons)
	e22:SetTarget(cm.splimit)
	c:RegisterEffect(e22)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCountLimit(1)
	e1:SetCondition(cm.atkcon)
	e1:SetTarget(cm.mvtg)
	e1:SetOperation(cm.mvop)
	c:RegisterEffect(e1)
end
function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xa91)
end
function cm.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED) and c:IsAttackAbove(3000)
end
function cm.negcons(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	return a and a:IsType(TYPE_LINK) and d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:GetControler()~=d:GetControler()
end
function cm.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b2=Duel.IsExistingMatchingCard(cm.mvfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b2 end
end
function cm.mvop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if Duel.IsExistingMatchingCard(cm.mvfilter2,tp,LOCATION_MZONE,0,1,nil,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g1=Duel.SelectMatchingCard(tp,cm.mvfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		if not tc1 then return end
		Duel.HintSelection(g1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g2=Duel.SelectMatchingCard(tp,cm.mvfilter3,tp,LOCATION_MZONE,0,1,1,tc1)
		Duel.HintSelection(g2)
		local tc2=g2:GetFirst()
		Duel.SwapSequence(tc1,tc2)
		if e:GetHandler():IsRelateToEffect(e) and d:IsFaceup() and d:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetValue(d:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
			d:RegisterEffect(e1)
		end
	end
end
function cm.mvfilter2(c,tp)
	return c:IsFaceup()  and c:GetSequence()<5 and c:IsSetCard(0xa91)
		and Duel.IsExistingMatchingCard(cm.mvfilter3,tp,LOCATION_MZONE,0,1,c)
end
function cm.mvfilter3(c)
	return c:IsFaceup()  and c:GetSequence()<5 and c:IsSetCard(0xa91)
end