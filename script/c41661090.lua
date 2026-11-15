--帕拉斯的代行·断罪
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,s.mfilter,2,127,false)
	--①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×800，不受攻击力低于自身的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--②：主要阶段才能发动。自己展示卡组1只怪兽，对方展示卡组1只怪兽。那之后，自己可以把那些怪兽送去墓地或者在持有者场上特殊召唤。这个回合，对方不能把魔法·陷阱卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.revtg)
	e3:SetOperation(s.revop)
	c:RegisterEffect(e3)
	--③：对方的怪兽被破坏时才能发动。对方受到那些怪兽原本攻击力的合计数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetCondition(s.damcon)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.mfilter(c)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_MONSTER)
end
function s.atkval(e,c)
	--只有融合召唤的这张卡才计算素材加成（离场后用其他方式回到场上时素材已失去）
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return 0 end
	return c:GetMaterialCount()*800
end
function s.efilter(e,te)
	local c=e:GetHandler()
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():GetAttack()<c:GetAttack()
end
function s.tantei(c)
	return c:IsSetCard(0x1d5c) and c:IsType(TYPE_MONSTER)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER)
			or Duel.IsExistingMatchingCard(Card.IsType,1-tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Group.CreateGroup()
	--自己展示卡组1只怪兽
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
		if g1:GetCount()>0 then
			Duel.ConfirmCards(1-tp,g1)
			Duel.ShuffleDeck(tp)
			g:Merge(g1)
		end
	end
	--对方展示卡组1只怪兽
	if Duel.IsExistingMatchingCard(Card.IsType,1-tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local g2=Duel.SelectMatchingCard(1-tp,Card.IsType,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
		if g2:GetCount()>0 then
			Duel.ConfirmCards(tp,g2)
			Duel.ShuffleDeck(1-tp)
			g:Merge(g2)
		end
	end
	--有「侦探」怪兽的场合，那些怪兽送去墓地或者在持有者场上特殊召唤
	if g:GetCount()==0 or not g:IsExists(s.tantei,1,nil) then return end
	if not c:IsRelateToEffect(e) then return end
	local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
	if opt==0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	else
		local g1=g:Filter(Card.IsControler,nil,tp)
		local g2=g:Filter(Card.IsControler,nil,1-tp)
		if g1:GetCount()>0 then
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
		if g2:GetCount()>0 then
			Duel.SpecialSummon(g2,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
	--这个回合，对方不能把魔法·陷阱卡的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.damfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetBaseAttack()>0
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil,1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.damfilter,nil,1-tp)
	local dmg=g:GetSum(Card.GetBaseAttack)
	if dmg>0 then
		Duel.Damage(1-tp,dmg,REASON_EFFECT)
	end
end
