-- 创炎世火-谢尔宾斯基 (ID: 23600117)
local s,id,o=GetID()
local SET_CHOUEN=0xd85 -- 「创炎」字段

function s.initial_effect(c)
	-- 连接召唤手续：包含连接怪兽的「创炎」怪兽4只以上
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,4,5,s.lcheck)

	-- 连接召唤时，可以让自己魔陷区的炎属性怪兽当作连接素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_SZONE,0)
	e0:SetTarget(s.matszfilter)
	e0:SetValue(s.matval)
	c:RegisterEffect(e0)

	-- 连接召唤成功的场合施加全回合誓约（非炎属性怪兽不能召唤·特殊召唤）
	local e_oath=Effect.CreateEffect(c)
	e_oath:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e_oath:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e_oath:SetCode(EVENT_SPSUMMON_SUCCESS)
	e_oath:SetCondition(s.oathcon)
	e_oath:SetOperation(s.oathop)
	c:RegisterEffect(e_oath)

	-- ①：对方不能对应自己的「创炎」魔法·陷阱卡的效果的发动把效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，送墓魔陷区表侧表示卡发动，3选1适用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- ③：从魔法与陷阱区域特殊召唤的场合，这张卡不受「创炎」卡以外的卡效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.immcon)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)

	-- 全局计数注册：监听全回合非炎属性怪兽的召唤·特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 素材常规过滤（场上怪兽或魔陷区炎属性怪兽）
function s.matfilter(c,lc,sumtype,tp)
	return c:IsLinkSetCard(SET_CHOUEN) or (c:IsLocation(LOCATION_SZONE) and c:IsAttribute(ATTRIBUTE_FIRE))
end

-- 整体素材合法性：必须包含连接怪兽，且若此前召唤过非炎属性则禁止连接召唤
function s.lcheck(g,lc,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK)
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

-- 魔陷区素材过滤
function s.matszfilter(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER)
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,not mg or not mg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE)
end

-- 召唤誓约计数过滤
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.oathcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.oathop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ①效果：封锁对方连锁
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(SET_CHOUEN) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

-- ②效果：Cost 过滤（魔陷区表侧表示卡）
function s.costfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- ②效果：分支 1 盖放「创炎」魔陷过滤
function s.setfilter(c)
	return (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

-- ②效果：分支 2 场上·墓地怪兽放置过滤
function s.plfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
end

-- ②效果：分支 3 特殊召唤永续魔法状态炎属性怪兽过滤
function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
		and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
		and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end

	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off]=3
		off=off+1
	end

	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)

	if sel==1 then
		e:SetCategory(CATEGORY_DECKDES+CATEGORY_LEAVE_GRAVE)
	elseif sel==2 then
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
	elseif sel==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 分支 1：盖放「创炎」魔陷
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif sel==2 then
		-- 分支 2：场上·墓地怪兽当作永续魔法放置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	elseif sel==3 then
		-- 分支 3：特召魔陷区当作永续魔法的炎属性怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ③效果：从魔陷区特殊召唤的判定与全抗
function s.immcon(e)
	return e:GetHandler():IsSummonLocation(LOCATION_SZONE)
end
function s.immval(e,te)
	return not te:GetHandler():IsSetCard(SET_CHOUEN)
end