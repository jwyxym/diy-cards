local s,id=GetID()

function s.initial_effect(c)
	-- 超量召唤：8星怪兽×3
	-- 同时包含：对方场上有2只以上攻击表示怪兽时，可以在自己场上的攻击表示怪兽上重叠召唤
	aux.AddXyzProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),nil,nil)
	c:EnableReviveLimit()

	-- 自肃判定：特招成功前后全方位锁死
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(s.spcost)
	e0:SetOperation(s.spactivate)
	c:RegisterEffect(e0)

	-- ①：临时全抗（直到连锁结束不受其他效果影响）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(s.immcon)
	e1:SetTarget(s.immtg)
	e1:SetOperation(s.immop)
	c:RegisterEffect(e1)

	-- ②：战斗抗性
	-- 战破抗性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 战斗中全抗（不受对方发动效果影响）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.batcon)
	e3:SetValue(s.batfilter)
	c:RegisterEffect(e3)

	-- ③：战斗后升阶（特殊召唤 四手修罗）
	-- 记录战斗过的信息
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- 升阶效果
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.rankupcon)
	e5:SetTarget(s.rankuptg)
	e5:SetOperation(s.rankupop)
	c:RegisterEffect(e5)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 自肃相关函数
function s.counterfilter(c)
	return c:IsCode(id) or c:IsCode(id+5)
end
function s.spcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.spactivate(e,c,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not (c:IsCode(id) or c:IsCode(id+5))
end

-- 超量召唤相关函数
-- 超量素材过滤 & 上叠条件总阀门
function s.ovfilter(c)
	-- 1. 获取当前准备超量的玩家（也就是该素材怪兽目前的控制者）
	local tp = c:GetControler()
	
	-- 2. 校验自肃：本回合如果特招过别的怪兽，强行判定“素材不合格”，熄灭额外卡组
	if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)~=0 then return false end
	
	-- 3. 校验场地环境：对方场上必须有2只以上表侧攻表怪兽，否则“素材不合格”
	local g = Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and tc:IsAttackPos() end, tp, 0, LOCATION_MZONE, nil)
	if g:GetCount() < 2 then return false end
	
	-- 4. 校验素材本身：必须是表侧攻击表示
	return c:IsFaceup() and c:IsAttackPos()
end
function s.xyzcon(e,tp,og,lp,minc,maxc)
	-- 校验：本回合是否特招过其他怪兽
	if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)~=0 then return false end
	
	
	-- 校验：对方场上是否有2只以上表侧攻击表示怪兽
	local g=Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and tc:IsAttackPos() end,tp,0,LOCATION_MZONE,nil)
	
	return g:GetCount()>=2
end

-- ① 临时全抗相关
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() -- 只要不是自己发动
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end

-- ② 战斗中抗性相关
function s.batcon(e)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function s.batfilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- ③ 升阶特招相关
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.rankupcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.rankupfilter(c,e,tp,mc)
	return c:IsCode(id+5) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) 
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.rankuptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.rankupfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rankupop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.rankupfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			Duel.Overlay(sc,Group.FromCards(c))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end