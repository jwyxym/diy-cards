local s,id=GetID()

-- 请替换成「算子械」系列实际的 setcode
local SET_OPERATOR=0x404

-- 快速幂取模：base^exp mod mod
local function pow_mod(base,exp,mod)
	if mod<=1 then return 0 end
	exp=math.floor(exp or 0)
	if exp<0 then exp=0 end
	base=math.floor(base or 0)%mod
	if base<0 then base=base+mod end

	local res=1%mod
	while exp>0 do
		if exp%2==1 then
			res=(res*base)%mod
		end
		base=(base*base)%mod
		exp=math.floor(exp/2)
	end
	return res
end

function s.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_OPERATOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.initial_effect(c)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_ACTIVATE)
	e:SetCode(EVENT_FREE_CHAIN)
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e:SetCountLimit(1,id)
	e:SetTarget(s.target)
	e:SetOperation(s.activate)
	c:RegisterEffect(e)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and s.tfilter(chkc)
	end

	local n=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)

	-- 发动时按“对象 ATK 会 +11”来预判是否可能成立
	local function valid_target(c)
		if not s.tfilter(c) then return false end
		if n<=1 then return false end

		local b=c:GetLevel()
		local atk=c:GetAttack()+11  -- 效果处理时会先加11
		local def=c:GetDefense()
		local rhs=pow_mod(b,def,n)

		return spg:IsExists(function(sc)
			local a=sc:GetLevel()
			return pow_mod(a,atk,n)==rhs
		end,1,nil)
	end

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and spg:GetCount()>0
			and Duel.IsExistingTarget(valid_target,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,valid_target,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not s.tfilter(tc) then return end

	-- ① 先让场上所有怪兽攻击力+11（包括里侧；里侧翻面后体现）
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc2 in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(11)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e1)
	end
	Duel.BreakEffect()

	-- ② 加攻后再重新计算 n 和对象当前数值
	local n=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if n<=1 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local atk=tc:GetAttack() -- 已包含 +11
	local rhs=pow_mod(tc:GetLevel(),tc:GetDefense(),n)

	local function spfilter2(c)
		if not s.spfilter(c,e,tp) then return false end
		local a=c:GetLevel()
		return pow_mod(a,atk,n)==rhs
	end

	if not Duel.IsExistingMatchingCard(spfilter2,tp,LOCATION_DECK,0,1,nil) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,spfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g2:GetCount()>0 then
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
end